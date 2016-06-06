/* vccomparevar.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - vccomp.p,vccompare.p,vccompare-dat.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        29.01.2013 damir.
*/
def {1} shared var v-dt1 as date.
def {1} shared var v-dt2 as date.
def {1} shared var p-type as char.

def {1} shared temp-table wrk1
    field txb as char
    field bank as char
    field rmz_jou as char
    field acc as char
    field cif as char
    field cifname as char
    field type as char
    field jh as inte
    field rdt as date
    field jdt as date
    field amt as deci
    field crc as inte
    field drgl as inte
    field crgl as inte
    field KOd as char
    field KBe as char
    field KNP as char
    field note as char
    field sub as char
    field SendRec as char
    field AtrContract as char
index idx txb ascending
          cif ascending
          amt ascending
          crc ascending
          jdt ascending
          SendRec ascending
          AtrContract ascending
          sub ascending
index idx2 type ascending
           jdt ascending.

def {1} shared temp-table wrk2
    field txb as char
    field bank as char
    field cifname as char
    field type as char
    field drgl as inte
    field crgl as inte
    field contract as char
    field ps as char
    field jh as inte
    field jdt as date
    field rdt as date
    field amt as decimal
    field crc  as int
    field KOd as char
    field KBe as char
    field KNP as char
    field note as char
    field cif as char
    field dntype as char
    field cttype as char
index idx txb ascending
          cif ascending
          amt ascending
          crc ascending
          jdt ascending
          dntype ascending
index idx2 type ascending.


