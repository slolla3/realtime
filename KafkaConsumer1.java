package kafkaconsumer1;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.common.serialization.LongDeserializer;
import org.apache.kafka.common.serialization.StringDeserializer;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
//import java.util.concurrent.ExecutorService;
import java.util.concurrent.*;
import org.apache.kafka.common.errors.WakeupException;
import org.apache.kafka.connect.mongodb.MongodbSinkTask;
import org.apache.kafka.common.annotation.InterfaceStability;
import org.apache.kafka.connect.connector.ConnectRecord;
import org.apache.kafka.connect.data.Schema;
import org.apache.kafka.connect.data.SchemaBuilder;
import org.apache.kafka.connect.data.Struct;
import org.apache.kafka.connect.mongodb.MongodbSinkConnector;
import org.apache.kafka.connect.sink.SinkRecord;

/**
 *
 * @author ADMIN
 */
public class KafkaConsumer1 implements Runnable {
  private final KafkaConsumer<String, String> consumer;
  private final List<String> topics;
  private final int id;
  public KafkaConsumer1(int id,
                      String groupId, 
                      List<String> topics) {
    this.id = id;
    this.topics = topics;
    Properties props = new Properties();
    props.put("bootstrap.servers", "localhost:9092");
    props.put("group.id", groupId);
    props.put("key.deserializer", StringDeserializer.class.getName());
    props.put("value.deserializer", StringDeserializer.class.getName());
    this.consumer = new KafkaConsumer<>(props);
  }
 
  @Override
  public void run() {
    try {
      consumer.subscribe(topics);

      MongodbSinkTask mst=new MongodbSinkTask();
      MongodbSinkConnector connector = new MongodbSinkConnector();
      try{
        connector.start(MongodbConnectHelper.buildSourcePropertiesWithURI());
        List<Map<String, String>> taskConfigs = connector.taskConfigs(1);
        mst.start(taskConfigs.get(0));
      }
      catch(Exception exp)
      {
          System.out.println("err mst start "+exp.toString());
      }
      Collection<org.apache.kafka.connect.sink.SinkRecord> collection=new ArrayList<SinkRecord>();

      while (true) {
        System.out.println("..");
        ConsumerRecords<String, String> records = consumer.poll(Long.MAX_VALUE);
        for (ConsumerRecord<String, String> record : records) {
          HashMap<String, Object> data = new HashMap<>();
          data.put("partition", record.partition());
          data.put("offset", record.offset());
          data.put("value", record.value());
          System.out.println(this.id + ": " + data);
          try{
 final Schema keySchema = SchemaBuilder.struct()
      .field("data", Schema.STRING_SCHEMA)
      .build();              
  final Struct key = new Struct(keySchema)
      .put("data", record.value());
            SinkRecord sr=new SinkRecord("mydevicestopic", 0, Schema.INT8_SCHEMA, this.id, keySchema, key, record.offset());
            
            
            //SinkRecord temp = new SinkRecord(topic, id, Schema.INT8_SCHEMA, sr, Schema.INT8_SCHEMA, sdata, id);
            collection.add(sr);
          }
          catch(Exception exp)
          {
            System.out.println("err sinkrecord "+exp.toString());
          }

        }
        try{
            mst.put(collection);          
        }
        catch(Exception exp)
        {
            System.out.println("err mst put coll "+exp.toString());
        }
      }     
    } catch (WakeupException e) {
      // ignore for shutdown 
      e.printStackTrace();
    } finally {
      consumer.close();
    }
  }

  public void shutdown() {
    consumer.wakeup();
  }
  
  public static void main(String[] args) { 
    int numConsumers = 1;
    String groupId = "consumer-tutorial-group";
    List<String> topics = Arrays.asList("mydevicestopic");
    ExecutorService executor = java.util.concurrent.Executors.newFixedThreadPool(numConsumers);

    final List<KafkaConsumer1> consumers = new ArrayList<>();
    for (int i = 0; i < numConsumers; i++) {
      KafkaConsumer1 consumer = new KafkaConsumer1(i, groupId, topics);
      consumers.add(consumer);
      executor.submit(consumer);
    }

    Runtime.getRuntime().addShutdownHook(new Thread() {
      @Override
      public void run() {
        for (KafkaConsumer1 consumer : consumers) {
          consumer.shutdown();
        } 
        executor.shutdown();
        try {
          executor.awaitTermination(
                  5000, TimeUnit.MILLISECONDS);
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    });
  }
  
}
