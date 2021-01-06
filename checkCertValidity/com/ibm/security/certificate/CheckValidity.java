package com.ibm.security.certificate;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;

public class CheckValidity {

	public static void main(String[] args) {
		
		// Check the number of parameters passed
		if (args.length < 3) {
			System.err.println("usage: com.ibm.security.certificate.CheckValidity keystorePath keystoreType keystorePassword");
			System.exit(1);
		}
		
		// load the variables from the information passed
		String keystorePath = args[0];
		String keystoreType = args[1].toLowerCase();
		String[] keystorePasswords = args[2].split("\\|");
		boolean expired = false;
		
		try {
			KeyStore ks = KeyStore.getInstance(keystoreType);
			
			// load the keystore with trying different passwords, if necessary
			for (String s: keystorePasswords) {
				try {
					char[] keystorePassword = s.toCharArray();
					ks.load(new FileInputStream(keystorePath), keystorePassword);
					break; // indicates keystore was loaded
				} catch (FileNotFoundException e) {
					e.printStackTrace(System.err);
					System.exit(1);
				} catch (IOException e) {	
					if (e.getCause() instanceof UnrecoverableKeyException) {
						System.err.println("bad password trying anohther ...");
					} else {
						e.printStackTrace(System.err);
						System.exit(1);
					}
				}
			}
			
			// get the aliases from the keystore
			Enumeration<String> aliases = ks.aliases();
			
			while (aliases.hasMoreElements()) {
				
				// get the certificate and check validity
				String alias = aliases.nextElement();	
				
				X509Certificate certificate = (X509Certificate) ks.getCertificate(alias);
				Date expiry = certificate.getNotAfter();
				
				// compare dates using older Java APIs
				Date today = new Date();
				Calendar calendar = Calendar.getInstance();
				calendar.setTime(expiry);
				calendar.add(Calendar.DATE, -30);
				Date daysPrior = calendar.getTime();
				
				if (today.after(daysPrior)) {
					System.err.println("Expired or expiring: " + alias + " : " + expiry);
					expired = true;
				}
			}
			
			if (expired) {
				System.exit(1);
			} 
			
		} catch (KeyStoreException e) {
			e.printStackTrace(System.err);
			System.exit(1);
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace(System.err);
			System.exit(1);
		} catch (CertificateException e) {
			e.printStackTrace(System.err);
			System.exit(1);
		}
	}

}
