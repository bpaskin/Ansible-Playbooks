This is a playbook that searches directories for keystores (jks and p12) and checks the valdiity of the certs.  The certs are valid if they are not expired or expiring in 30 days.  The 30 days can be changed in the Java program.  

Java was used instead of straight playbooks using Python since keystores are a Java construct and have an API that is better than calling the `keytool` Java tool since the results are different between different versions of the JDK/JRE.  

The Playbook searches for the Java in certain paths and the first instance will be used.  Java 6+ is requried and the Java application uses Java < 8 standards.  The Playbook will search for keystores with jks endings and then pkcs12 endings.  The Java program is called for each keystore with the proper type, JKS or PKCS12, and possible passwords.  

The Java application will try to load the keystore with one of the passwords and will continue until either the password is correct or the no passwords work.  After the program will get a list of certificate alias in the keystore and go one by one to check the validity of the certificate - 30 days.  If 1 certificate is expired or expiring then the application will fail and so will the playbook.

Variables that need to be passed in:

```
keystorePaths: /usr/WebSphere/usr,/usr/WebSphere/wlp/usr/shared,/usr/WebSphere/AppServer/profiles
password: MyPass|WebAS
```
