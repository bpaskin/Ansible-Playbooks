Short script with supporting xml files and directories how certain customers create Liberty bundles with the necessary Java 8 and Java 11.  The necessary files are placed in the appropriate place within the structure.  For example, a java directory is created and the Java 8 mand 11 runtimes are placed there with the java.env file.  Other files are placed in the template, so when a new App Server is created it has the necessary files.  Others are placed in the shared directories with the JDBC or MQ drivers, not included here.  In the end the `wlp/usr` directory should be moved out and placed somewhere else for easier upgrades.