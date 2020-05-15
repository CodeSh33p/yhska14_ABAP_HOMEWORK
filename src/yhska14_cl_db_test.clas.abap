CLASS yhska14_cl_db_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS yhska14_cl_db_test IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA:itab TYPE TABLE OF yhska_14_prog.

*   read current timestamp
    GET TIME STAMP FIELD DATA(zv_tsl).

*   fill internal travel table (itab)
    itab = VALUE #(
  ( name = 'test'
  shares = '50.26'
  trends = '5.1'
  rating = '65.1'
  change = '7.15'
  currentversion ='1.1.1.0'
  currency_code = '%'
  releasedate = '20191110'
  favorite = '0'
  wikiurl = 'https://en.wikipedia.org/wiki/Go_(programming_language)'
  helloworld = '/ Hello world in Go package main import "fmt" func main() { fmt.Printf("Hello World\n") }' )
  ( name = 'test2'
  shares = '10'
  trends = '+3.1'
  rating = '55.1'
  change = '-7.15'
  currentversion ='1.1.1.0'
  currency_code = '%'
  releasedate = '20191110'
  favorite = '1'
  wikiurl = 'https://en.wikipedia.org/wiki/Go_(programming_language)'
  helloworld = '/ Hello world in Go package main import "fmt" func main() { fmt.Printf("Hello World\n") }' )
   ).


*   delete existing entries in the database table
    DELETE FROM yhska_14_prog.
*
*   insert the new table entries
*    INSERT yhska_14_prog FROM TABLE @itab.

*    READ ENTITY yhska14_i_prog_m
*            FIELDS ( name shares trends rating change currentversion currency_code
*                     releasedate favorite wikiurl wikiscrab helloworld
*                     last_changed_by last_changed_at )
*             WITH VALUE #( ( name = 'test' ) )
*             RESULT DATA(lt_prog)
*             FAILED data(lt_failed)
*             REPORTED DATA(lt_reported).
*

*   check the result
    SELECT * FROM yhska_14_prog INTO TABLE @itab.
    out->write( sy-dbcnt ).
    out->write( 'Travel data inserted successfully!').
    out->write( itab ).
  ENDMETHOD.

ENDCLASS.
