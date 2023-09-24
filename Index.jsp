<%-- 
    Document   : newjsp3
    Created on : Apr 3, 2019, 7:27:37 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@page import="java.util.Arrays.*"%>

<%@page import="org.bson.*"%>
<%@page import="com.mongodb.client.AggregateIterable"%>

<%@page import="com.mongodb.*" %>
<%@page import="java.util.*" %>
<%@page import="com.google.gson.*" %>
<%@page import="fusioncharts.FusionCharts" %>


<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="refresh" content="30">
        
         <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>
  
  
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Dashboard</title>
         <script type="text/javascript" src="js/fusioncharts.js"></script>
        <script type="text/javascript" src="js/themes/fusioncharts.theme.fusion.js"></script>
 
           <script src="fusioncharts.js"></script>
        <script src="fusioncharts.theme.fint.js"></script>
        <script src="fusioncharts.charts.js"></script>
        
    </head>
    <body>
        <h1>Device Live Dashboard</h1>
        <%



         Mongo mongoClient = new Mongo("localhost" , 27017 );
 
         //connecting to the database
         DB db = mongoClient.getDB( "mydevicestopic" );
         System.out.println("Connected to database successfully");
         
         //Hashmap is created to store the values from the database
         //HashMap<String,String> labelValue = new HashMap<String,String>();
         
         //fetching the collection from the database
        DBCollection collection = db.getCollection("mydevicestopic");
       
        //Selects the documents in a collection and returns a cursor to the selected documents
         //DBCursor cursor = collection.find().limit(20);
         DBCursor cursor = collection.find().skip((int)collection.count()-10);
         //.sort({_id:1}).limit(50);
         out.write("<div class='container'>");
         out.write("<table class='table table-striped'>");
 
         while(cursor.hasNext()) {
           out.write("<tr>");
             DBObject o = cursor.next();
             out.write("<td>");
                String label = (String) o.get("_id").toString() ; 
                out.write(label+"</td>");
                                String value = ((String) o.get("data"));

                                out.write("<td>"+value);
                
                out.write("</td>");
              //labelValue.put(label, value);
            out.write("</tr>");
         }
         out.write("</table>");
         out.write("</div");
  %>
 
  
  <%
  
      DB db2 = mongoClient.getDB( "fusion_demo" );
         System.out.println("Connected to database successfully");
         
         //Hashmap is created to store the values from the database
         HashMap<String,Integer> labelValue = new HashMap<String,Integer>();
         
         //fetching the collection from the database
        DBCollection collection2 = db2.getCollection("population");
        
        //Selects the documents in a collection and returns a cursor to the selected documents
         DBCursor cursor2 = collection2.find();
 
         while(cursor2.hasNext()) {
           
             DBObject o = cursor2.next();
             
                String label = (String) o.get("label") ; 
                int value = ((Number) o.get("value")).intValue();
              labelValue.put(label, value);
            
                }
         
  %>
  
  
          <div id="chart"></div>
 
        <%
         
            Gson gson = new Gson();
            
                Map<String, String> chartobj = new HashMap<String, String>();
            // The &apos;chartobj&apos; map object holds the chart attributes and data.
            chartobj.put("caption", "Split of Devices by Location");
            chartobj.put("subCaption" , "Current");
            chartobj.put("paletteColors" , "#0075c2");
            chartobj.put("bgColor" , "#ffffff");
            chartobj.put("showBorder" , "0");
            chartobj.put("theme","fint");
            chartobj.put("showPercentValues" , "1");
            chartobj.put("decimals" , "1");
            chartobj.put("captionFontSize" , "14");
            chartobj.put("subcaptionFontSize" , "14");
            chartobj.put("subcaptionFontBold" , "0");
            chartobj.put("toolTipColor" , "#ffffff");
            chartobj.put( "toolTipBorderThickness" , "0");
            chartobj.put("toolTipBgColor" , "#000000");
            chartobj.put("toolTipBgAlpha" , "80");
            chartobj.put("toolTipBorderRadius" , "2");
            chartobj.put("toolTipPadding" , "5");
            chartobj.put("showHoverEffect" , "1");
         
           // to store the entire data object
            ArrayList arrData = new ArrayList();
            for(Map.Entry m:labelValue.entrySet()) 
            {
                // to store the key value pairs of label and value object of the data object
                Map<String, String> lv = new HashMap<String, String>();
                lv.put("label", m.getKey().toString() );
                lv.put("value", m.getValue().toString());
                arrData.add(lv);             
            }
            //close the connection.
            cursor.close();
 
            //create &apos;dataMap&apos; map object to make a complete FC datasource.
             Map<String, String> dataMap = new LinkedHashMap<String, String>();  
        /*
            gson.toJson() the data to retrieve the string containing the
            JSON representation of the data in the array.
        */
         dataMap.put("chart", gson.toJson(chartobj));
         dataMap.put("data", gson.toJson(arrData));
 
            FusionCharts columnChart= new FusionCharts(
            "column2d",// chartType
                        "chart1",// chartId
                        "600","400",// chartWidth, chartHeight
                        "chart",// chartContainer
                        "json",// dataFormat
                        gson.toJson(dataMap) //dataSource
                    );
            %>
            
<!--    Step 5: Render the chart    -->                
            <%=columnChart.render()%>
            
            
    </body>
</html>

