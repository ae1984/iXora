/* rblcons_k.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1-4-2-13
 * AUTHOR
        23.07.2012 Lyubov
 * BASES
        BANK TXB
 * CHANGES
        02.07.2013 yerganat - tz1889, добавление вывода счета ГК

*/

{name2sort.i}

def shared var v-dat as date.
def shared var v-ofc like txb.ofc.ofc.
def shared var ii as integer initial 0.
def shared var pr as integer.
def shared var v-type as integer init 1.
def shared var text1 as char format "x(20)".

def shared temp-table temp
    field aaa  like txb.aaa.aaa
    field middl as char
    field cif  like txb.aaa.cif
    field name like txb.aaa.name
    field sort as char
    field bal  as decimal
    field gl  like txb.aaa.gl
    index main is primary sort cif middl aaa.

def shared temp-table t-vars
  field name as char
  index main is primary name.

def shared var v-payee as char.
if pr = 1 then do:
    for each txb.cif no-lock,
        each txb.aaa of txb.cif no-lock:
      for each txb.aas where txb.aas.aaa = txb.aaa.aaa no-lock break by txb.aas.aaa:
         if ((txb.aas.sta = 0) and can-find(first t-vars where index(caps(txb.aas.payee), t-vars.name) > 0)) or (pr = 1 and (txb.aas.sta = 4 or txb.aas.sta = 9 or txb.aas.sta = 15 or txb.aas.sta = 5 )) or (pr = 2 and txb.aas.sta <> 4 and txb.aas.sta <> 0 and txb.aas.sta <> 9 and txb.aas.sta <> 15 and txb.aas.sta <> 5) then do:
           find temp where temp.cif = txb.cif.cif and temp.aaa = txb.aaa.aaa no-lock no-error.
           if not avail temp then do:
             create temp.
             assign temp.aaa  = txb.aaa.aaa
                    temp.middl = substr(txb.aaa.aaa, 4, 3)
                    temp.cif  = txb.aaa.cif
                    temp.name = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name))
                    temp.bal = txb.aaa.cr[1] - txb.aaa.dr[1].
                    temp.gl  = txb.aaa.gl.
                    temp.sort = name2sort(temp.name).

             find txb.gl where txb.gl.gl = txb.aaa.gl no-lock no-error.
             if txb.gl.type = "a" or txb.gl.type = "e" then temp.bal = - temp.bal.
           end.
         end.
      end.
    end.
end.
else do:
    for each txb.aas no-lock break by txb.aas.aaa:
       if ((txb.aas.sta = 0) and can-find(first t-vars where index(caps(txb.aas.payee), t-vars.name) > 0)) or (pr = 1 and (txb.aas.sta = 4 or txb.aas.sta = 9 or txb.aas.sta = 15 or txb.aas.sta = 5)) or (pr = 2 and txb.aas.sta <> 4 and txb.aas.sta <> 0 and txb.aas.sta <> 9 and txb.aas.sta <> 15 and txb.aas.sta <> 5) then do:
         find txb.aaa where txb.aaa.aaa = txb.aas.aaa no-lock no-error.

         if not avail txb.aaa then next.
         else do:
           find temp where temp.cif = txb.aaa.cif and temp.aaa = txb.aaa.aaa no-lock no-error.
           if not avail temp then do:
             find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
             create temp.
             assign temp.aaa  = txb.aaa.aaa
                    temp.middl = substr(txb.aaa.aaa, 4, 3)
                    temp.cif  = txb.aaa.cif
                    temp.name = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name))
                    temp.bal = txb.aaa.cr[1] - txb.aaa.dr[1].
                    temp.gl  = txb.aaa.gl.
                    temp.sort = name2sort(temp.name).

             find txb.gl where txb.gl.gl = txb.aaa.gl no-lock no-error.
             if txb.gl.type = "a" or txb.gl.type = "e" then temp.bal = - temp.bal.
           end.
         end.
       end.
     end.
end.