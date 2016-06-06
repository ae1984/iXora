/* ianketa2.p
 * MODULE
        Потребкредит
 * DESCRIPTION
        Обработка интернет-анкет, пост-гцвп
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
        20/05/2005 madiyar
 * CHANGES
        03/05/2006 madiyar - небольшие исправления
        18/10/2006 madiyar - исправил опечатку
        24/04/2007 madiyar - веб-анкеты
        25/04/2007 madiyar - по коммерсантам ГЦВП не отправляем
        03/05/2007 madiyar - вообще ГЦВП не отправляем
        14/09/2007 madiyar - ГЦВП отправляем
*/

{global.i}
{pk.i}
{sysc.i}
{pk-sysc.i}

define shared temp-table t-anket like pkanketh.
def var v-refus as char no-undo init ''.
define shared var v-fmsg as char no-undo init ''.

def var v-type as char no-undo.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.
v-type = pkanketa.id_org.

{pkkritlib.i}

for each t-anket:
delete t-anket.
end.

for each pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln no-lock:
  create t-anket.
  buffer-copy pkanketh to t-anket.
end.

/* просматриваем анкету на предмет корректив менеджера */
for each pkkrit where pkkrit.priz = "1" and lookup (s-credtype, pkkrit.credtype) > 0 use-index kritcod no-lock:
    
    if lookup(pkkrit.kritcod, "gcvpres,commentary") > 0 then next.
    
    find first t-anket where t-anket.kritcod = pkkrit.kritcod no-lock no-error.
    if avail t-anket then do:
        
        if t-anket.value3 <> t-anket.value4 then do:
            if t-anket.value3 = '1' then do:
                if pkkrit.kritspr ne '' then do:
                    if num-entries(pkkrit.kritspr) = 1 then find first bookcod where bookcod.bookcod = pkkrit.kritspr and bookcod.code = t-anket.value1 no-lock no-error.
                    else find first bookcod where bookcod.bookcod = entry(integer(s-credtype),pkkrit.kritspr) and bookcod.code = t-anket.value1 no-lock no-error.
                    if avail bookcod then do:
                        t-anket.rating = int(bookcod.info[1]).
                        t-anket.resdec[5] = int(bookcod.info[2]).
                    end.
                    else do:
                        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
                        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
                    end.
                end.
                else do:
                    t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
                    t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
                    /* для критерия "кол-во несовершеннолетних детей" рейтинг умножаем на кол-во */
                    if t-anket.kritcod = "child16" then do:
                        t-anket.rating = t-anket.rating * integer(t-anket.value1).
                        t-anket.resdec[5] = t-anket.resdec[5] * integer(t-anket.value1).
                    end.
                end.
            end.
            if (t-anket.value3 = '0' or t-anket.value1 = '' or trim(t-anket.value1) = '0') and lookup(t-anket.kritcod, 'apart1,mname,apart1s,mnames') = 0 then do:
                t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
                t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
                /* для критерия "кол-во несовершеннолетних детей" рейтинг умножаем на кол-во */
                if t-anket.kritcod = "child16" then do:
                    t-anket.rating = t-anket.rating * integer(t-anket.value1).
                    t-anket.resdec[5] = t-anket.resdec[5] * integer(t-anket.value1).
                end.
            end.
        end.
        
    end. /* if avail t-anket */
    
end.

if s-credtype <> '7' then do:

find first pkkrit where pkkrit.kritcod = "gcvpres" no-lock no-error.
if avail pkkrit then do:
  
  find first t-anket where t-anket.kritcod = pkkrit.kritcod no-lock no-error.
  if avail t-anket then do:
     run value(pkkrit.proc) (t-anket.kritcod).
     if t-anket.value3 = '1' then do:
        if pkkrit.kritspr ne '' then do:
           if num-entries(pkkrit.kritspr) = 1 then find first bookcod where bookcod.bookcod = pkkrit.kritspr and bookcod.code = t-anket.value1 no-lock no-error.
           else find first bookcod where bookcod.bookcod = entry(integer(s-credtype),pkkrit.kritspr) and bookcod.code = t-anket.value1 no-lock no-error.
           if avail bookcod then do:
              t-anket.rating = int(bookcod.info[1]).
              t-anket.resdec[5] = int(bookcod.info[2]).
           end.
           else do:
              t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
              t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
           end.
        end. 
        else do:
           t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
           t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
        end.
     end.
     if (t-anket.value3 = '0' or t-anket.value1 = '' or trim(t-anket.value1) = '0') and lookup(t-anket.kritcod, 'apart1,mname,apart1s,mnames') = 0 then do:
        t-anket.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
        t-anket.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
     end.
     
  end. /* if avail t-anket */
  
end.

end. /* if s-credtype <> '7' */

/* автоматические критерии */
for each pkkrit where pkkrit.priz = "0" and lookup (s-credtype, pkkrit.credtype) > 0 use-index kritcod no-lock:
  
  find t-anket where t-anket.kritcod = pkkrit.kritcod no-error.
  if not avail t-anket then do:
      create t-anket.
      assign t-anket.bank = s-ourbank
             t-anket.credtype = s-credtype
             t-anket.ln = int(pkkrit.ln)
             t-anket.kritcod = pkkrit.kritcod
             t-anket.value1 = trim(pkkrit.res[2])
             t-anket.value2 = ""
             t-anket.value3 = ""
             t-anket.value4 = "".
  end.
  run value(pkkrit.proc) (t-anket.kritcod).
  
end.


do transaction:

  for each pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln:
    delete pkanketh.
  end.
  
  for each t-anket:
    create pkanketh.
    buffer-copy t-anket to pkanketh.
    pkanketh.ln = s-pkankln.
  end.
  
end. /* transaction */



