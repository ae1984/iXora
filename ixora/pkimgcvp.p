/* pkimgcvp.p 
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Импорт данных из файла-ответа ГЦВП в анкету заемщика
 * RUN
 
 * CALLER
        pknew0.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-x-1, 4-x-2
 * AUTHOR
        05.07.2003 marinav
 * CHANGES
        05.08.2003 marinav - автоматическое заполнение поля gcvpsum из ответа ГЦВП
        09.10.2003 marinav - вынесение заявки на кредитный комитет
        24.10.2003 nadejda - добавила виды кредитов - все Быстрые для вынесения на КредКом
        29.10.2003 marinav - pkanketh.rescha[3] заменено с yes на 1 
        05.12.2003 nadejda - если статус анкеты стоит "ожидание ответа ГЦВП" - тоже принять файл независимо от предыдущего приема!
        25.12.2003 nadejda - анализ ответа ГЦВП вынесен в отдельную программу pkanlgcvp.p, 
                             сразу после анализа ответа пишутся в критерий "gcvpsum" признак КредКом и чистый доход
        06.01.2004 nadejda - исправлена ошибка проставления рейтинга
        26.01.2004 nadejda - ТОЛЬКО при статусе 03 писать результат анализа ответа и менять статус!
        16/03/2006 madiyar - проверка на наличие введенной суммы чистого среднемесячного дохода (jobpr2)
        17/05/2006 madiyar - пропускаем пустые строки в ответе из гцвп
*/

{global.i}
{pk.i}
{pk-sysc.i}
{sysc.i}
 
def var v-gcvptxt as char.
def var v-diri as char.
def var fname as char.
define var v-rnn as char.
define var v-mon as inte.
define var v-monn as inte.
DEFINE var l-kred as inte init 0.
def var v-dohod as decimal no-undo.
def var v-vichet as decimal no-undo.

def var v-sum as deci format "->>>,>>>,>>9.99".
def var v-suml as logical.
def var v-nal as decimal init 0.
def var v-entry as inte.    /*разделитель ; */
def var v-entry1 as inte.   /*разделитель | */
def var i as inte.
def var v-str as char.
def var sumb as deci.
def var v-month as inte.
def var v-date1 as date.
def var v-date2 as date.
def var v-newfile as logical.

define temp-table t-gcvp 
       field txt as char format "x(50)".


if s-pkankln = 0 then return.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype 
     and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype 
     and  pkanketh.ln = s-pkankln and pkanketh.kritcod = "sik" no-lock no-error.

if not avail pkanketh then return.


if pkanketh.rescha[3] = "" then do:
  message skip " Запрос данных в ГЦВП по СИК '" + pkanketh.value1 + "' не был отправлен !" skip(1)
          view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
  return.
end.
v-gcvptxt = pkanketh.rescha[3].

v-newfile = (num-entries(pkanketh.rescha[3], ";") = 1).

/* если записано только имя файла - принять файл */
/* 05.12.2003 nadejda - если статус анкеты стоит "ожидание ответа ГЦВП" - тоже принять файл независимо от предыдущего приема! */
if v-newfile or pkanketa.sts = "03" then do:
  /* файл был, но ответ не импортировался или надо повторить импорт */
  fname = entry(1, pkanketh.rescha[3], ";").
  v-diri = get-sysc-cha ("pkgcvi").

  FILE-INFO:FILE-NAME = v-diri + fname.

/*  find first gcvp where gcvp.nfile = substr(fname,5) no-error .
    if avail gcvp and FILE-INFO:FILE-TYPE ne ? then do:
       gcvp.answ = FILE-INFO:FILE-SIZE. 
       release gcvp.
    end.
 */

  IF FILE-INFO:FILE-TYPE = ? THEN do:
    message skip "Файл ответа " + fname + " из ГЦВП не пришел" skip(1) 
            view-as alert-box button Ok title "Внимание!".
    return.
  end.

  input from value(v-diri + fname).

  REPEAT on error undo, leave:
     create t-gcvp.
     import unformatted t-gcvp no-error. 
    
     IF ERROR-STATUS:ERROR then do:
        run savelog("gcvpout","Ошибка импорта").
        return.
     END.
  END. 
  input close.

  run savelog("gcvpout", "Принятие ответа из ГЦВП " + fname + " " + string(time, "HH:MM:SS")).

  find current pkanketh exclusive-lock.
  pkanketh.rescha[3] = fname.
  for each t-gcvp.
     if trim(t-gcvp.txt) <> '' then pkanketh.rescha[3] = pkanketh.rescha[3] + ";" + t-gcvp.txt. 
  end.
  find current pkanketh no-lock.
  v-gcvptxt = pkanketh.rescha[3].

end.

/* 26.01.2004 nadejda - записывать новый анализ только при статусе 03! */
if v-newfile or pkanketa.sts = "03" /*(pkanketa.sts > "00" and pkanketa.sts < "10")*/ then do:
  /* 25.12.2003 nadejda - приняли файл - проанализируем и запишем результат анализа */
  l-kred = 0.

  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
     pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobs" no-lock no-error.

  if pkanketa.rdt < 01/05/2007 then do:
     run pkanlgcvp (v-gcvptxt, pkanketh.value1, output l-kred, output v-nal).

     find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype 
          and pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" exclusive-lock no-error.
     pkanketh.value1 = string(v-nal).
     pkanketh.rescha[3] = string(l-kred).
     find current pkanketh no-lock.
  end.
  else do:
    if pkanketa.rdt < 06/17/2008 then do:
       if entry(7, (entry(2, v-gcvptxt, ";")), "|") = "0" and num-entries((entry(2, v-gcvptxt, ";")), "|") = 9 then do:

       if pkanketh.value1 = '50' or  pkanketh.value1 = '60' then do:
         find first bookcod where bookcod.bookcod = "pkankkat" and bookcod.code = pkanketh.value1 no-lock no-error.
           if avail bookcod then do:
             v-dohod = integer (bookcod.info[3]).
             v-vichet = integer (bookcod.info[4]).
             v-nal = decimal(entry(9, (entry(2, v-gcvptxt, ';')), '|')) * v-dohod * (100 - v-vichet) / 100.
           end.
       end.
       else
          /* чисты доход рассчитывается "начисленный - пенсионный - подоходный" */
          v-nal = decimal(entry(9, (entry(2, v-gcvptxt, ';')), '|')) * 8.1 + 975.2.       

       /* если отчислений меньше 6 , то на кредитный комитет */
       if decimal(entry(8, (entry(2, v-gcvptxt, ';')), '|')) < 6 then l-kred = 1.

       find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype 
                and pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" exclusive-lock no-error.
       pkanketh.value1 = string(v-nal).
       pkanketh.rescha[3] = string(l-kred).
       find current pkanketh no-lock.
       end.
    end.
    else do:
       if entry(10, (entry(2, v-gcvptxt, ";")), "|") = "0" and num-entries((entry(2, v-gcvptxt, ";")), "|") = 10 then do:

       if pkanketh.value1 = '50' or  pkanketh.value1 = '60' then do:
         find first bookcod where bookcod.bookcod = "pkankkat" and bookcod.code = pkanketh.value1 no-lock no-error.
           if avail bookcod then do:
             v-dohod = integer (bookcod.info[3]).
             v-vichet = integer (bookcod.info[4]).
             v-nal = decimal(entry(9, (entry(2, v-gcvptxt, ';')), '|')) * v-dohod * (100 - v-vichet) / 100.
           end.
       end.
       else
          /* чисты доход рассчитывается "начисленный - пенсионный - подоходный" */
          v-nal = decimal(entry(9, (entry(2, v-gcvptxt, ';')), '|')) * 8.1 + 975.2.       

       find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype 
                and pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" exclusive-lock no-error.
       pkanketh.value1 = string(v-nal).
       pkanketh.rescha[3] = string(l-kred).
       find current pkanketh no-lock.
       end.
    end. 
  end.
 
end.


find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
            pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobs" no-lock no-error.
if pkanketa.rdt < 01/05/2007 then do:             
     run pkgcvprep(v-gcvptxt, pkanketh.value1).
end.
else
   if pkanketa.rdt < 06/17/2008 then  run pkgcvprep1(v-gcvptxt, pkanketh.value1).
                                else  run pkgcvprep2(v-gcvptxt, pkanketh.value1). 


/* 14.11.2003 nadejda - если статус не отказ и до принятия решения клиентом - проставить статус */
/* 26.01.2004 nadejda - менять статус только при статусе 03! */
if pkanketa.sts = "03" /*pkanketa.sts > "00" and pkanketa.sts < "10"*/ then do:


  if lookup (s-credtype, "1,5,6,7") > 0 then do:
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype 
         and pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" no-lock no-error.
    v-sum = decimal(pkanketh.value1).


    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype 
       and pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobpr2" no-lock no-error.
    if not avail pkanketh or pkanketh.value1 = "" then do:
      message " Не введена сумма чистого дохода (интервал) " view-as alert-box buttons ok.
      return.
    end.
    find bookcod where bookcod.bookcod = "pkankdoh" and bookcod.code = pkanketh.value1 no-lock no-error.
    if entry(3, bookcod.name, " ") = "..." 
        then v-suml = decimal(entry(1, bookcod.name, " ")) < v-sum.
        else v-suml = decimal(entry(1, bookcod.name, " ")) <= v-sum and decimal(entry(3, bookcod.name, " ")) >= v-sum.

    find first pkkrit where pkkrit.kritcod = "gcvpsum" no-lock no-error.

    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype 
       and  pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" exclusive-lock no-error.                   
    if v-suml then do:
      pkanketh.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1])).
      pkanketh.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])).
      /* такое сочетание показывает, что ответ ГЦВП принимался повторно */
      pkanketh.value3 = "1".
      pkanketh.value4 = "0".
    end.
    else do:
      pkanketh.rating = integer(entry(integer(s-credtype),pkkrit.rating_nc[1])).
      pkanketh.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_nc[2])).
      pkanketh.value3 = "0".
      pkanketh.value4 = "0".
    end.
    find current pkanketh no-lock.
    
    /* проверка критериев отказа и выдача результата на экран в нужном виде для каждого вида кредита */
    run value ("pkafterank-" + s-credtype).

  end.
end.



