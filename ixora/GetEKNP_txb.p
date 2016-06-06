/* GetEKNP_txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        21.12.2012 damir - changing copy GetEKNP.p, uses TXB base. Внедрено Т.З. № 1620.
*/

def input parameter vjh as inte.
def input parameter vln as inte.
def input parameter vdc as char.
def input-output parameter KOd as char.
def input-output parameter KBe as char.
def input-output parameter KNP as char.
def var i as int.

   find txb.trxcods where txb.trxcods.trxh = vjh
                  and txb.trxcods.trxln = vln
                  and txb.trxcods.codfr = "spnpl" no-lock no-error.
   if available txb.trxcods then KNP = txb.trxcods.code.

   find txb.trxcods where txb.trxcods.trxh = vjh
                  and txb.trxcods.trxln = vln
                  and txb.trxcods.codfr = "locat" no-lock no-error.
   if available txb.trxcods then do:
      if vdc = "D" then substring(KOd,1,1) = substring(txb.trxcods.code,1,1).
      else substring(KBe,1,1) = substring(txb.trxcods.code,1,1).
   end.

   find txb.trxcods where txb.trxcods.trxh = vjh
                  and txb.trxcods.trxln = vln
                  and txb.trxcods.codfr = "secek" no-lock no-error.
   if available txb.trxcods then do:
      if vdc = "D" then substring(KOd,2,1) = substring(txb.trxcods.code,1,1).
      else substring(KBe,2,1) = substring(txb.trxcods.code,1,1).
   end.
   /*aigul*/
   find first txb.jh where txb.jh.jh = vjh no-lock no-error.
   if avail txb.jh then do:
       if txb.jh.sub <> "RMZ" then do:
           find first txb.jl where txb.jl.jh = vjh no-lock no-error.
           if avail txb.jl then do:
           i = r-index( txb.jl.rem[1], 'RMZ' ).
                find first txb.sub-cod where txb.sub-cod.acc = trim( substring(txb.jl.rem[1], i, 10 )) and txb.sub-cod.ccod = "eknp" no-lock no-error.
                if avail txb.sub-cod then KOd = substr(txb.sub-cod.rcode,1,2).
           end.
        end.
   end.
   /**/


