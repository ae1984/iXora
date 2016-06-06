/* chk_valcon.p
 * MODULE
        Проверка необходимости валютного контроля внутреннего платежа
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
        19/03/2009 galina
 * BASES
        BANK
 * CHANGES
        20.08.2009 galina - не контролируем переводы между собственными счетами.
*/


def input parameter p_doc like joudoc.docnum.
def output parameter p_dres as integer.
def output parameter p_cres as integer.
def output parameter result as integer.


def var v-cif1 as char.
def var v-cif2 as char.

result = 0.
p_dres = 1.
p_cres = 1.

find first joudoc where joudoc.docnum = p_doc no-lock no-error.

if avail joudoc then do:
  find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
  if avail aaa then do:
    find first cif where cif.cif = aaa.cif no-lock no-error.
    if avail cif then v-cif1 = cif.cif. 
    if avail cif and substr(cif.geo,3,1) <> '1' then do: 
      result = result + 1.
      p_cres = p_cres + 1.
    end.  
  end. 
  
  find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
  if avail aaa then do:
    find first cif where cif.cif = aaa.cif no-lock no-error.
    if avail cif then v-cif2 = cif.cif. 
    if avail cif and substr(cif.geo,3,1) <> '1' then  do:
      result = result + 1.
      p_dres = p_dres + 1.
    end.  
  end. 

  if joudoc.drcur <> 1 or  joudoc.crcur <> 1 then result = result + 1.
  
  if v-cif1 = v-cif2 then result = 0.   
  
end.