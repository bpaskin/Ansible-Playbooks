SCRIPT_VERSION=1.0.0.0
LIBERTY_HOME=""
JAVA_HOME=""
USRDIR=""


# Check Liberty Compliance (AIX and Linux)
#
# v1.0.0.0 (28/08/2020)
# Brian S Paskin

# Check path for Liberty
if [ -d "/usr/WebSphere/wlp/bin" ]; then
	LIBERTY_HOME="/usr/WebSphere/wlp"
elif [ -d "/usr/WebSphere85/wlp/bin" ]; then
	LIBERTY_HOME="/usr/WebSphere85/wlp"
fi

if [ -z "$LIBERTY_HOME" ]; then
	echo "Liberty not found on the system"
	exit 1
fi

# Check usr directory
WAS_DIR=$(dirname $LIBERTY_HOME)
if [ -d "$WAS_DIR/usr" ]; then
        USRDIR="$WAS_DIR/usr"
else
        USRDIR="$LIBERTY_HOME/usr"
fi

SERVERS=`ls -l $USRDIR/servers | egrep '^d' | awk '{print $9}'`
JRES=`ls -l $LIBERTY_HOME/java | egrep '^d' | awk '{print $9}'`

echo -e "#########################################################################################"
echo -e "# Date:\t\t\t`date`"
echo -e "# Hostname:\t\t`hostname`"
echo -e "# Operating System:\t`uname`"
echo -e "# Running As:\t\t`whoami`"
echo -e "# Install path:\t\t$LIBERTY_HOME"
echo -e "# USR path:\t\t$USRDIR"
echo -e "# Liberty version:\t`$LIBERTY_HOME/bin/productInfo version | grep \"Product version:\" | cut -d \":\" -f 2``$LIBERTY_HOME/bin/productInfo version | grep \"Product edition:\" | cut -d \":\" -f 2`"

for JRE in $JRES; do
	echo -e "# Java Version:\t\t`$LIBERTY_HOME/java/$JRE/jre/bin/java -fullversion 2>&1`" 

	if [ "$JRE" == "8.0" ]; then
		JAVA_HOME="$LIBERTY_HOME/java/$JRE"
	fi

	if [ "$JRE" != "8.0" ] && [ "$JRE" != "11.0" ]; then
		echo "!! FAIL:  JRE is not recognized"
	fi
done

echo -e "#########################################################################################"


# 03.01.00 file permissions
PERMS=`find $LIBERTY_HOME ! -user wsadmin -o ! -group wsadm -o ! -perm 750 | head -n 1`
if [ "$PERMS" != "" ]
then
	echo "!! FAIL: 03.01.00 - file permissions and ownership"
fi

# check JDBC files is correct
if [ `ls -l $USRDIR/shared/resources/jdbc |  grep -i db2 | wc -l` -gt 1 ]; then
	echo "!! FAIL: There should only be 1 DB2 JDBC library"
fi

if [ `ls -l $USRDIR/shared/resources/jdbc |  grep -i oracle | wc -l` -gt 1 ]; then
	echo "!! FAIL: There should only be 1 Oracle JDBC library"
fi

if [ `ls -l $USRDIR/shared/resources/jdbc |  grep -i mssql | wc -l` -gt 1 ]; then
	echo "!! FAIL: There should only be 1 MSSQL library"
fi

# loop through servers
for SERVER in $SERVERS; do
	echo ""
	echo "Server : $SERVER"
	echo "----------------"
	echo ""

	# call the java process to read the files and determine if TCS is followed
	#$JAVA_HOME/bin/java -cp "lib/*" com.ibm.tcs.liberty.CheckCompliance $LIBERTY_HOME/usr/servers/$SERVER/server.xml

	# check for bad passwords
	PASSWORDS=`grep password $USRDIR/servers/$SERVER/*.xml | grep -v {aes} | head -n 1`
	if [ "$PASSWORDS" != "" ]
	then
		echo "!! FAIL: passwords not encrypted properly"
	fi

	# check dropins
	if [ -d "$USRDIR/servers/$SERVER/dropins" ]; then
		if [ `ls $USRDIR/servers/$SERVER/dropins/ | wc -l` -gt 0 ]; then
			echo "!! FAIL: dropins files found."
		fi
	fi

	if [ `grep dropinsEnabled=\""true\"" $USRDIR/servers/$SERVER/*.xml | wc -l` -gt 0 ]; then
		echo "!! FAIL: dropins needs to be disabled"
	fi

	# check alias for *
	if [ `grep hostAlias $USRDIR/servers/$SERVER/*.xml | grep "[*]" | wc -l` -gt 0 ]; then
		echo "!! FAIL: * are not allowed in host aliases"
	fi 
	
	# check for derby db
	if [ `grep -i derby $USRDIR/servers/$SERVER/*.xml | wc -l` -gt 0 ]; then
		echo "!! FAIL: Derby is not a valid database"
	fi

	# Check datasources
	if [ `grep -i dataSource $USRDIR/servers/$SERVER/*.xml | grep -vi isolationLevel=\""TRANSACTION_READ_COMMITTED\"" |  grep -vi statementCacheSize | wc -l` -ne 0 ]; then
		echo "!! FAIL: Datasources not setup correctly"
	fi

	# check connection manager
	if [ `grep -i connectionManager $USRDIR/servers/$SERVER/*.xml | grep -vi purgePolicy=\""FailingConnectionOnly\"" |  grep -vi agedTimeout=\""-1\""  | wc -l` -ne 0 ]; then
		echo "!! FAIL: Connection Manager is not setup correctly"
	fi
	
	# check if this an old version of server.xml found in each server dir
	if [ `grep httpPort $USRDIR/servers/$SERVER/*.xml | wc -l` -gt 0 ]; then

		# check HTTP is disabled
		if [ `grep httpPort=\""-1\"" $USRDIR/servers/$SERVER/server.xml | wc -l` -eq 0 ]; then
			echo "!! FAIL: HTTP port must be disabled"
		fi
		
		# check SSL
		if [ `grep defaultSSLConfig $USRDIR/servers/$SERVER/server.xml | grep securityLevel=\""HIGH\"" | grep "TLSv1.2" | wc -l` -ne 1 ]; then
			echo "!! FAIL: Default SSL settings are not correct"
		fi		
	
		if [ `grep anthemSSLSettings $USRDIR/servers/$SERVER/server.xml | grep securityLevel=\""HIGH\"" | grep "TLSv1.2" | wc -l` -ne 1 ]; then
			echo "!! FAIL: Anthem SSL settings are not correct"
		fi

		# check DB configs are correct
		if [ `grep jdbc/db2 $USRDIR/servers/$SERVER/server.xml | grep *.jar | wc -l` -ne 1 ]; then
			echo "!! FAIL: DB2 settings are not correct"
		fi
		
		if [ `grep jdbc/oracle $USRDIR/servers/$SERVER/server.xml | grep *.jar | wc -l` -ne 1 ]; then
			echo "!! FAIL: Oracle settings are not correct"
		fi
		
		if [ `grep  jdbc/mssql $USRDIR/servers/$SERVER/server.xml | grep *.jar | wc -l` -ne 1 ]; then
			echo "!! FAIL: MSSQL settings are not correct"
		fi	
	
		# check web app security
		if [ `grep logoutOnHttpSessionExpire=\""true\"" $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 1 ] || [ `grep httpOnlyCookies=\""true\"" $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 1 ] || [ `grep ssoRequiresSSL=\""true\"" $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 1 ] || [ `grep useAuthenticationDataForUnprotectedResource=\""true\"" $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 1 ]; then
			echo "!! FAIL: Web App Security is incorrect"
		fi	
	
		# check web container settings	
		if  [ `grep disableXPoweredBy=\""true\"" $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 1 ] ||  [ `grep serveServletsByClassnameEnabled=\""false\"" $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 1 ]; then
			echo "!! FAIL: Web Container settings are incorrect"
		fi	

		# check session settings
		if [ `grep cookiesEnabled=\""true\"" $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 1 ] || [ `grep cookieSecure=\""true\"" $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 1 ] || [ `grep cookieHttpOnly=\""true\"" $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 1 ] || [ `grep cookieMaxAge=\""-1\"" $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 1 ]; then
			echo "!! FAIL: HTTP Session settings are incorrect"
		fi	

		# check for items in the server.xml that should not be there
		if [ `grep -i datasouce $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 0 ]; then
			echo "!! FAIL: Datasources do not belong in the server.xml"
		fi

		if [ `grep -i webApplication $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 0 ] || [ `grep -i enterpriseApplication $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 0 ] || [ `grep -i springBootApplication $USRDIR/servers/$SERVER/server.xml | wc -l` -ne 0 ]; then
			echo "!! FAIL: Application definitions do not belong in the server.xml"
		fi

		# check if extra features are enabled
		if [ `grep -i "<feature>"  $USRDIR/servers/$SERVER/server.xml | wc -l` -gt 7 ]; then
			echo "!! FAIL: Extra features enabled in server.xml"
		fi
		
	fi
done

