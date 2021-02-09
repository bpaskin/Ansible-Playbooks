This updates a tWAS profile that uses a standalone LDAP for security and allows for changing the userid and password based on the environment. The target sytsem will be queried for the location of tWAS profiles, and if found, will loop through them trying to update the userid and password using the `wsadmin.sh` command and a jython script that is passed.

In each profile the `wsadmin.sh` script is called and the jython script location is passed with the userid, and `environment:password`.  The passwords should not be encrypted.  The jython script will check the environment and see if it matches the Bind DN.  If it does then the userid is check.  If the userid is already there, then the updating of the password is skipped.  This is because in a distirbuted environment the DMGR may have already updated the userid and password.  Otherwise the userid and password are updated and Nodes synchronized.  Finally the `profile/properties/soap.client.props` is updated with the new userid and password.

The script requires the following extra variables:

```
newUserId: MyNewUserId
devPw: MyDevelopmentPassword
sitPw: MySITPassword
uatPw: MyUATPassword
prodPw: MyProductionPassword
```

The shell command will need to be changed for each user as the names of the LDAP Bind DN probably do not match
`{{ newUserId }} dev:{{ devPw }},sit:{{ sitPW }},uat:{{ uatPw }},prod:{{ prodPw }}`

In this case the dev, sit, uat, prod should be changed for the proper Bind DN name.
