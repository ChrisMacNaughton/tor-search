mkdir -p bin
javac -d bin `find src -name '*.java'` 
java -Xmx1024m -classpath ./bin:./lib/postgresql-9.2-1002.jdbc4.jar com.elocal.solrimport.SolrImporter
