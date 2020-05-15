CLASS yhska14_cl_tableexport_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    DATA:
      lt_pyplTable       TYPE STANDARD TABLE OF yhska_14_prog,
      lt_tiobeTable      TYPE STANDARD TABLE OF yhska_14_prog,
      lt_wikiTable       TYPE STANDARD TABLE OF yhska_14_prog,
      lt_helloworldTable TYPE STANDARD TABLE OF yhska_14_prog,
      lt_matchTable      TYPE STANDARD TABLE OF yhska_14_prog,
      ls_tableLine       TYPE yhska_14_prog.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS yhska14_cl_tableexport_test IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA(lo_pypl) = NEW ycl_pypl_parser( ).
    DATA(lo_tiobe) = NEW ycl_tiobe_parser( ).
    DATA(lo_wiki) = NEW ycl_wiki_parser( ).
    DATA(lo_hello) = NEW ycl_hello_world_parser( ).

    lo_pypl->get_table( IMPORTING ex_insertTable = lt_pyplTable ).
    lo_tiobe->get_table( IMPORTING ex_insertTable = lt_tiobeTable ).
    lo_wiki->get_table( IMPORTING ex_insertTable = lt_wikiTable ).
    lo_hello->get_table( IMPORTING ex_insertTable = lt_helloworldTable ).


    SELECT *
    From yhska_14_prog
    INTO TABLE @data(lt_prog).


    LOOP AT lt_pyplTable ASSIGNING FIELD-SYMBOL(<ls_pyplTable>).
        IF <ls_pyplTable> is ASSIGNED.
            READ TABLE lt_prog
            with key name = <ls_pyplTable>-name
            INTO DATA(ls_prog).
            If sy-subrc = 0.
                <ls_pyplTable>-favorite = ls_prog-favorite.
                <ls_pyplTable>-last_changed_by = ls_prog-last_changed_by.
                <ls_pyplTable>-last_changed_at = ls_prog-last_changed_at.
            ENDIF.
            IF <ls_pyplTable>-favorite IS INITIAL.
                <ls_pyplTable>-favorite = 0.
            ENDIF.
            READ TABLE lt_helloworldTable
                WITH KEY name = <ls_pyplTable>-name
                INTO data(ls_tableline).
            If sy-subrc = 0.
                <ls_pyplTable>-helloworld = ls_tableline-helloworld.
            ENDIF.
            READ TABLE lt_tiobeTable
                WITH KEY name = <ls_pyplTable>-name
                INTO ls_tableline.
            If sy-subrc = 0.
                <ls_pyplTable>-rating = ls_tableline-rating.
                <ls_pyplTable>-change = ls_tableline-change.
            ENDIF.
            READ TABLE lt_wikiTable
                WITH KEY name = <ls_pyplTable>-name
                INTO ls_tableline.
            If sy-subrc = 0.
                <ls_pyplTable>-wikiurl = ls_tableline-wikiurl.
                <ls_pyplTable>-releasedate = ls_tableline-releasedate.
            ENDIF.
            <ls_pyplTable>-currency_code = '%'.
        ENDIF.
    ENDLOOP.

    MODIFY yhska_14_prog FROM TABLE @lt_pypltable.
*    out->write( lt_pyplTable ).
*    out->write( lt_tiobeTable ).
*     out->write( lt_wikiTable ).
*    out->write( lt_helloworldTable ).

  ENDMETHOD.
ENDCLASS.
