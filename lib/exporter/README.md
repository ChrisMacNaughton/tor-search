# Exporting Accounts/Profiles for Solr

## Background

In elocal_web, we use [Solr](http://lucene.apache.org/solr/) for performing fuzzy searches.  Right now, we are indexing three object types: Accounts, Profiles, and Categories and we use the [Sunspot](http://sunspot.github.com) gem to make this happen.  All this is fine and wonderful when changing just one object.  However...when you want to index a large number of records, it is really, really slow (exercise for the reader...why?).  One way to speed up this is to have Solr read data from a CSV file.  This project exports the Account and Profile data into a CSV that can then be easily imported in to Solr

**WARNING** This export does transformations that will match up with the Solr schema.  **IF THE SCHEMA CHANGES, THIS SCRIPT NEEDS TO BE MODIFIED**

## Performing the Export

We have configured a run script, ```run.sh``` that will compile and run the exporter.  We configure the 

The following environment args are used:

- **PGDATABASE** The PostgreSQL database to connect to.  Defaults to _elocal\_development_
- **PGUSER**     The user to connect as.  Defaults to _elocal_
- **PGPASSWORD** The password to use when connecting to PG.  Defaults to _sYmmetRy7_
- **IMPORT\_ACCOUNT\_WHERE** An additional where clause to tack on as an account filter.  If set to blank, all accounts will be exported.Defaults to the empty string.
- **IMPORT\_PROFILE\_WHERE** An additional where clause to tack on as an profile filter.  If set to blank, all profiles will be exported.Defaults to the empty string.
- **IMPORT\_DO\_ACCOUNT**    Should accounts be exported.  Needs to be set to Y for the account export to occur.  By default, it is empty.
- **IMPORT\_DO\_PROFILE**    Should profiles be exported.  Needs to be set to Y for the profile export to occur.  By default, it is empty.

So to do a full export from the database elocal\_stage you would run.

```IMPORT_DO_ACCOUNT=Y IMPORT_DO_PROFILE=Y PGDATABASE=elocal_stage ./run.sh```

This will create files accounts.csv and profiles.csv in your current database.

You will notice that there is no option for setting what hostname to connect to when doing the export.  This is 100% intentional.  Please export on the server with the database on it.

## Importing the Data

Congratulations, you have acquired a database CSV file.  Now to import the data.  For full documentation on importing data, refer to [Solr's UpdateCSV Page](http://wiki.apache.org/solr/UpdateCSV).  For our purposes, the following will suffice.  Again, note the localhost, these commands must be run **ON THE SOLR SERVER**.

### Importing Accounts with CURL to a clean index

    # Import Accounts
    curl http://localhost:8982/solr/update/csv -d "stream.file=$PWD/accounts.csv&stream.contentType:text/plain;charset=utf-8&f.type.split=true&f.category_ids_im.split=true&f.category_ids_im.separator=%7C&overwrite=false&commit=true"

    # Import Profiles
    curl http://localhost:8982/solr/update/csv -d "stream.file=$PWD/profiles.csv&stream.contentType:text/plain;charset=utf-8&f.type.split=true&f.category_ids_im.split=true&f.category_ids_im.separator=%7C&f.zip_code_ids_im.split=true&f.zip_code_ids_im.separator=%7C&f.city_ids_im.split=true&f.city_ids_im.separator=%7C&f.zip_points_ll_sm.split=true&f.zip_points_ll_sm.separator=%7C&f.city_points_ll_sm.split=true&f.city_points_ll_sm.separator=%7C&overwrite=false&commit=true"

### Inporting to update values

    # Import Accounts
    curl http://localhost:8982/solr/update/csv -d "stream.file=$PWD/accounts.csv&stream.contentType:text/plain;charset=utf-8&f.type.split=true&f.category_ids_im.split=true&f.category_ids_im.separator=%7C&commit=true"

    # Import Profiles
    curl http://localhost:8982/solr/update/csv -d "stream.file=$PWD/profiles.csv&stream.contentType:text/plain;charset=utf-8&f.type.split=true&f.category_ids_im.split=true&f.category_ids_im.separator=%7C&f.zip_code_ids_im.split=true&f.zip_code_ids_im.separator=%7C&f.city_ids_im.split=true&f.city_ids_im.separator=%7C&f.zip_points_ll_sm.split=true&f.zip_points_ll_sm.separator=%7C&f.city_points_ll_sm.split=true&f.city_points_ll_sm.separator=%7C&commit=true"

## Does This Matter

Yes.  Reindexing all accounts and profiles (about 6MM records for each) using Sunspot took 3-5 days.  Importing using a CSV took about 5 minutes.  So that's good.  For categories however, with only 600 records, the difference would be negligible.  Thus, I never wrote a categories exporter.
