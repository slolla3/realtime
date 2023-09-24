/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package kafkaconsumer1;

import java.util.HashMap;
import java.util.Map;

/**
 *
 * @author ADMIN
 */
public class MongodbConnectHelper {
    public static Map<String, String> buildSourcePropertiesWithURI(){
    	final Map<String, String> sourceProperties = new HashMap<>();
        sourceProperties.put("uri", "mongodb://localhost:27017");
        sourceProperties.put("batch.size", Integer.toString(100));
        sourceProperties.put("bulk.size", Integer.toString(1));
        sourceProperties.put("schema.name", "mydevicestopic");
        sourceProperties.put("topic.prefix", "mydevicestopic");
        sourceProperties.put("databases", "mydevicestopic");
        sourceProperties.put("mongodb.database", "mydevicestopic");
        sourceProperties.put("collections", "mydevicestopic");
        sourceProperties.put("topics", "mydevicestopic");
        sourceProperties.put("mongodb.collections", "mydevicestopic");
        return sourceProperties;
    }    
}
