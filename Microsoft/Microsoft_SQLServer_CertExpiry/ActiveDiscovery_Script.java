import com.santaba.agent.groovyapi.expect.Expect;
import com.santaba.agent.groovyapi.snmp.Snmp;
import com.santaba.agent.groovyapi.http.*;
import com.santaba.agent.groovyapi.jmx.*;
import org.xbill.DNS.*;
import groovy.sql.Sql // needed for SQL connection and query
import groovy.time.*;

hostname = hostProps.get("system.hostname");
user = hostProps.get("wmi.user");
pass = hostProps.get("wmi.pass");

SQLUrl = "jdbc:sqlserver://" + hostname + ";databaseName=master;integratedSecurity=true" //
sql = Sql.newInstance(SQLUrl, user, pass, 'com.microsoft.sqlserver.jdbc.SQLServerDriver')

sql.eachRow( 'SELECT name, expiry_date, issuer_name from sys.certificates'){
	// extract the actual results into variables
	cert_name = it.name.replaceAll("#",""); // remove the # from the name key
	cert_expiryDate = it.expiry_date.toString(); //extract timestamp into string
	cert_issuer = it.issuer_name;
	
	wildvalue=SpecialCharacterCheck(cert_name);
	
	println "${wildvalue}##${cert_name}##Expiry Date -> ${cert_expiryDate}####auto.CertificateIssuer=${cert_issuer}&auto.CertificateExpiryDate=${cert_expiryDate}"
}

sql.close() // close connection

// according to :
// https://www.logicmonitor.com/support/logicmodules/datasources/active-discovery/script-active-discovery
// active discovery WILDVALUE cannot contain  ['=',':','\','#','space'] characters
// the function below will get rid of those special characters if they exist
def SpecialCharacterCheck(value){
	//special characters not allowed in ActiveDiscovery
	def specialCharacters = ~/\=|\:|\\|\#|\s/

	//replace the special character by nothing & return the 'new' service name
	value=value.replaceAll(specialCharacters, '')
	//println(service); //DEBUG

	return value
}