package edu.harvard.coursereg

import static groovyx.net.http.ContentType.JSON
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method

import java.security.InvalidKeyException
import java.security.NoSuchAlgorithmException

import javax.crypto.BadPaddingException
import javax.crypto.Cipher
import javax.crypto.IllegalBlockSizeException
import javax.crypto.NoSuchPaddingException
import javax.crypto.SecretKey
import javax.crypto.spec.SecretKeySpec

import org.apache.commons.logging.LogFactory
import org.codehaus.groovy.grails.commons.ConfigurationHolder

class CourseRegistrationUtils {
	
	private static final log = LogFactory.getLog(this)
	def static config = ConfigurationHolder.config
	
	def static decryptId(String encid, String producerKey) {
		if (!producerKey) {
			if (config.isites.producer.key) {
				producerKey = config.isites.producer.key
			}
			else {
				log.error "Tool producer key is missing - cannot decrypt userid."
				return encid
			}
		}
		
		def decbytes = ciphering(Cipher.DECRYPT_MODE, encid.decodeHex() , producerKey);

		def decstr = new String(decbytes)
		
		log.info("decrypted param = " + decstr);
		
		def decid = decstr.split( '[|]' )[0]
		log.info("decrypted id (from split) = " + decid );

		return decid
	}
	
	def static decryptId(String encid) {
		return decryptId(encid, null)
	}
	
	private static byte[] ciphering(int way, byte[] input, String key) {
		try {
			Cipher cipher = Cipher.getInstance("RC4");
			boolean ok = false;
			try {
				SecretKey secretKey = new SecretKeySpec(key.getBytes(), "RC4");
				cipher.init(way, secretKey);

				ok = true;
			} catch (InvalidKeyException ike) {
				ike.printStackTrace();
			}

			if (ok != true)
				return null;

			try {
				byte[] inputArray = input;

				byte[] outputArray = cipher.doFinal(inputArray);

				return outputArray;
			} catch (IllegalBlockSizeException e) {
				e.printStackTrace();
			} catch (BadPaddingException e) {
				e.printStackTrace();
			}

		} catch (NoSuchAlgorithmException nsae) {
			System.out.println("No such algorithm!\n");
			nsae.printStackTrace();
		} catch (NoSuchPaddingException nspe) {
			System.out.println("No such padding!\n");
			nspe.printStackTrace();
		}
		return null;
	}
	
	def static findPerson(String userId) {
		def person
		def http = new HTTPBuilder(config.icommonsapi.url + "/people/by_id/" + userId)
		http.request(Method.GET, JSON) {
			response.success = {resp, json ->
				person = json.people[0]
				if (person.unknown) {
					log.error("Failed to find person for userId ${userId}")
				}
			}
		}
		return person
	}
	
}
