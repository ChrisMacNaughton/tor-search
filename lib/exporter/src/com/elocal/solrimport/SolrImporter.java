package com.elocal.solrimport;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
/*
 # Import Pages
curl http://localhost:8983/solr/update/csv -d "stream.file=$PWD/pages.csv&stream.contentType:text/plain;charset=utf-8&f.type.split=true&f.anchor_text.split=true&separator=,&commit=true"

# Import Images
curl http://localhost:8983/solr/update/csv -d "stream.file=$PWD/images.csv&stream.contentType:text/plain;charset=utf-8&f.type.split=true&f.anchor_text.split=true&commit=true"
  */
public class SolrImporter {
	private String _dbName, _dbUser, _dbPassword;
	private Connection _con;
	public SolrImporter() throws SQLException {

		_dbName = System.getenv("PGDATABASE");
		if (_dbName == null || _dbName.length() == 0) {
			_dbName = "tor_search_development";
		}
		_dbUser = System.getenv("PGUSER");
		if (_dbUser == null || _dbUser.length() == 0) {
			_dbUser = "tor_search";
		}
		_dbPassword = System.getenv("PGPASSWORD");
		if (_dbPassword == null || _dbPassword.length() == 0) {
			_dbPassword = "NLKEWYBTo47iylargBKS^%(48";
		}
		_con = DriverManager.getConnection("jdbc:postgresql://localhost/" + _dbName, _dbUser, _dbPassword);
		_con.setAutoCommit(false);
	}
	public static void main(String[] args) throws Exception{
		Class.forName("org.postgresql.Driver");
		new SolrImporter().run();
	}
	public void run() throws ClassNotFoundException, SQLException, IOException {
		//exportImages();
		exportPages();

		_con.close();
	}
	@SuppressWarnings("unchecked")
	private void exportPages() throws SQLException, IOException {
		PrintWriter out = new PrintWriter(new FileWriter("pages.csv"));
		out.println("id,type,id_i,title_texts,body_text,description_texts,domain_path_texts,path_texts,domain_id_i,link_count_i,anchor_text_text");
		PreparedStatement ps = _con.prepareStatement("select pages.id AS id, pages.title AS title, pages.body AS body, links.anchor_text AS anchor_text, pages.description AS description, pages.domain_id, domains.path as domain_path, pages.path as path, (select count(*) from links where links.to_target_id = pages.id and links.to_target_type = 'Page') as link_count from pages left join links on links.to_target_id = pages.id and links.to_target_type = 'Page' left join domains on domains.id = pages.domain_id where pages.title is not null and pages.title != '' and pages.description is not null and pages.description != '' and pages.no_crawl = 'f' and domains.blocked = 'f' order by domains.id",
		  ResultSet.TYPE_FORWARD_ONLY,
		  ResultSet.CONCUR_READ_ONLY);
		ps.setFetchSize(1000);
		ResultSet rs = ps.executeQuery();
		int pageId = -1;
		Set<String> links = null;
		Map<String,String> vals = null;

		String[] keys = {"title", "body", "description","domain_path","path","domain_id","link_count"};
		while(rs.next()) {
			int current_id = rs.getInt("id");
			if (pageId != current_id) {
				if (pageId > 0) {
					outputRow(out, pageId, "Page", keys, vals,Arrays.asList(links));
					if (pageId % 10 == 0) {
						out.flush();
					}
				}
				vals = new HashMap<String, String>();
				for (String k : keys) {
  				vals.put(k, rs.getString(k));
				}

				pageId = current_id;
				links = new HashSet<String>();
			}
			if (rs.getString("anchor_text") != null) {
				links.add(rs.getString("anchor_text"));
			} else {
				links.add("");
			}
		}
		if (pageId > 0) {
			outputRow(out, pageId, "Page", keys, vals,Arrays.asList(links));
		}
		rs.close();
		ps.close();
		out.close();
	}

	@SuppressWarnings("unchecked")
	private void exportImages() throws SQLException, IOException {
		PrintWriter out = new PrintWriter(new FileWriter("images.csv"));
		out.println("id,type,id_i,alt_text_text,anchor_text_text,domain_id_i");
		PreparedStatement ps = _con.prepareStatement("select images.id, coalesce(images.alt_text) as alt_text, coalesce(links.anchor_text) as anchor_text, images.domain_id from images left join links on links.to_target_id = images.id and links.to_target_type = 'Image' order by images.id",
		  ResultSet.TYPE_FORWARD_ONLY,
		  ResultSet.CONCUR_READ_ONLY);
		ps.setFetchSize(1000);
		ResultSet rs = ps.executeQuery();
		int pageId = -1;
		Set<String> links = null;
		Map<String,String> vals = null;

		String[] keys = {"anchor_text", "alt_text", "domain_id"};
		while(rs.next()) {
			int current_id = rs.getInt("id");
			if (pageId != current_id) {
				if (pageId > 0) {
					outputRow(out, pageId, "Image", keys, vals,Arrays.asList(links));
					if (pageId % 10 == 0) {
						out.flush();
					}
				}
				vals = new HashMap<String, String>();
				for (String k : keys) {
  				vals.put(k, rs.getString(k));
				}

				pageId = current_id;
				links = new HashSet<String>();
			}
			//if (rs.getString("anchor_text") != null) {
				links.add(rs.getString("anchor_text"));
			//}
		}
		if (pageId > 0) {
			outputRow(out, pageId, "Image", keys, vals, Arrays.asList(links));
		}
		rs.close();
		ps.close();
		out.close();
	}
	@SuppressWarnings("rawtypes")
	private void outputRow(PrintWriter out, int id, String type, String[] keys, Map<String,String> vals, List listOfVals) {
		StringBuilder sb = new StringBuilder("\"" + type + " " + id+ "\",\"" + type + ",ActiveRecord::Base\","+id);

		for (String k : keys) {

			String v = vals.get(k);
			//System.out.println(k + "-" + v);
			if (v == null) {
				v = "";
			} else {
				v = v.replaceAll("\"", "\"\"");
			}
			sb.append(",\"" + v.toString() + "\"");
		}
		for (Object o : listOfVals) {
			Set l = (Set)o;
			sb.append(",\"" + join(l).replaceAll("\"", "\"\"") + "\"");
		}
		out.println(sb.toString());
	}
	@SuppressWarnings("rawtypes")
	private String join(Collection l) {
		StringBuilder sb = new StringBuilder();
		for (Object o : l) {
			sb.append(sb.length() > 0 ? "|": "");
			sb.append(o.toString());
		}
		return sb.toString();
	}

}
