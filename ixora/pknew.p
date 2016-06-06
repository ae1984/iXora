/* pknew.p Потребкредиты
   Ввод новой анкеты

   01.02.2003 marinav 
   28.02.2003 nadejda - отбор по виду кредита
   03.03.2003 nadejda - расчет суммы и вообще все, что после сохранения анкеты, вынесено в отдельные проги для разных видов кредитов
   23.05.2003 nadejda - добавлено копирование критерия 'resaki' в pkanketa.rescha[2] 
                        value1 пишется не "", а значение по умолчанию pkkrit.res[2]
                        value3 теперь позволяет редактировать значение всегда, а не только когда 0

   28.05.2003 nadejda - изменено формирование полного имени - теперь вызывается процедура pkdeffio, 
                        формирует с учетом казахских букв

   02.06.2003 marinav - добавлен вызов процедуры для запроса в ГЦВП
   24.06.2003 nadejda - убрала присваивание пустого поля в t-anket.value1 в случае, когда help вернул пустую строку
   26.06.2003 nadejda - вопрос насчет послать в ГЦВП перенесла в процедуру обработки СИК
   21.07.2003 nadejda - выделила собственно редактирование анкеты в pknew0.p - чтобы можно было 
                             редактировать старую анкету для тех видов кредитов, где это разрешено
                      - добавила возможность возврата в редактирование анкеты

   07.08.2003 nadejda - заменила вызов sel на sel2, чтобы по F4 возвращалось в редактирование анкеты
   08.08.2003 nadejda - добавила копирование массивов rescha и resdec при копировании анкеты
   23.07.2004 saltanat - объявлена переменная v-trnum, с помощью которой будем заносить номер транзакции в таблицу pkanketa
   02/08/2005 madiyar - работа с фотографиями клиентов (только в Алматы)
   19/08/2005 madiyar - обработка совпадения с черным списком
   27/09/2005 madiyar - работа с фотографиями клиентов - добавил Атырау
   29/09/2005 madiyar - работа с фотографиями клиентов - добавил Уральск
   20/02/2006 madiyar - убрал лишнюю проверку фотографий
   14/03/06   marinav - поиск кода клиента по всей клиентской базе 
   19/04/06   marinav - поиск клиента с учетом type -  физ или юр лицо ( для ИП открывать новый код)
   07/07/06   marinav - заполнение поля jobrnn РНН организации
   02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
   04/09/2007 madiyar - программа 'Коммерсант' временно приостановлена
   04/06/2008 madiyar - валютные кредиты
   05/06/2008 madiyar - вынес выбор валюты из блока "if v-isedit"
   30/09/2009 galina - записываем номера анкет созаемщика в признак "subln" для родительской анкеты и номер главной анкеты в признаке "mainln" для анкеты созаемщика
*/

{mainhead.i}
{pk.i "new"}

/**
s-credtype = '3'.
**/

{pk-sysc.i}

if get-pksysc-log("pkstop") then do:
  message get-pksysc-char("pkstop") view-as alert-box information.
  return.
end.

def new shared var v-sta as inte init 0.
def new shared var v-trnum as integer format "zzzzzzz9" init 0.
def new shared var v-repeat as integer init 0.
def new shared var v-chtrans as integer init 0.
def new shared var v-refresh as logi init no.
/*
v-repeat =
0 - стандартные
1 - льготные условия для повторных
2 - льготные условия для повторных через кредком
*/

def var v-isedit as logical.
def var v-iscopy as logical.
def var v-select as integer init 3.
def var v-crcsel as integer init 0.

def var v-pkankln as inte.
def var v-goal as char.
def var v-sumq as deci.
def var v-summa as deci.
def var v-rateq as deci.
def var ja as log format "да/нет" init no.
def var v-name as char.
def var v-cif as char.
def var ddat as date.
/*
def var pcoun as integer.
*/
def var choice as logical.

def new shared var hanket as handle.
run pkkritlib persistent set hanket.
pause 0.


def new shared temp-table t-anket like pkanketh.

for each pkkrit where pkkrit.priz = "1" and lookup (s-credtype, pkkrit.credtype) > 0 use-index kritcod no-lock:
  create t-anket.
  assign t-anket.bank = s-ourbank 
         t-anket.credtype = s-credtype
         t-anket.ln = int (pkkrit.ln) 
         t-anket.kritcod = pkkrit.kritcod
         t-anket.value1 = trim(pkkrit.res[2]) 
         t-anket.value2 = ""
         t-anket.value3 = "" 
         t-anket.value4 = "".
end.

find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "anked" no-lock no-error.
v-isedit = (avail pksysc and pksysc.loval).


/* если для этого вида кредитов позволено редактирвать старые анкеты - выбираем действия с анкетой */

form 
  skip(1)
  v-pkankln        label " ЗАДАЙТЕ НОМЕР АНКЕТЫ " 
    validate (can-find(pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
              pkanketa.ln = v-pkankln no-lock), 
              " Нет анкеты с таким номером !")
    help " Уажите номер анкеты (F2 - поиск анкеты)" skip(1)
  with overlay side-label row 4 frame f-ank.

if v-isedit then do:
  v-select = 4.
  run sel2 ("ДЕЙСТВИЯ :", 
            " 1. Ввод новой анкеты | 2. Редактировать старую анкету | 3. Копия старой анкеты в новую | 4. ВЫХОД ", 
            output v-select).
  if v-select = 0 then v-select = 4.

  case v-select:
    when 1 then do: v-isedit = no. v-iscopy = no. end.
    when 2 then do: v-isedit = yes. v-iscopy = yes. end.
    when 3 then do: v-isedit = no. v-iscopy = yes. end.
    when 4 then return.
  end case.
  
  if v-iscopy then do:
    v-pkankln = 0.
    update v-pkankln with frame f-ank.
    if v-pkankln = 0 then return.
    
    for each t-anket:
      find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = v-pkankln and
           pkanketh.kritcod = t-anket.kritcod no-lock no-error.
      
      /* почему-то изначально был сделан excrpt для полей массивов, вспомнить бы почему... */
      if avail pkanketh then buffer-copy pkanketh except pkanketh.ln /*pkanketh.rescha pkanketh.resdec*/ to t-anket.
    end.
  end.
  
end.

if not (v-isedit or v-iscopy) then do:
  v-crcsel = 0.
  run sel2 ("ВАЛЮТА :", " 1. Тенге | 2. Доллары США | 3. ВЫХОД ", output v-crcsel).
  if v-crcsel <> 1 and v-crcsel <> 2 then return.
  
  if v-crcsel <> 1 then do:
      find first sysc where sysc.sysc = "rkcout" no-lock no-error.
      if avail sysc and sysc.loval then do:
          message "Филиал работает через кассу РКЦ, выдача кредитов в валюте невозможна!" view-as alert-box error.
          return.
      end.
  end.
  
end.


/* цикл редактирования анкеты */
repeat:
  run pknew0.
  
  case v-sta:
    when 1 then do:
      ja = no.
      message skip    " Произошла ошибка во время редактирования анкеты !"
              skip(1) " Повторить редактирование данных ?" skip(1) 
              view-as alert-box button yes-no title " ВНИМАНИЕ ! " update ja.
      if not ja then return.
    end.
    when 2 then do: run pksave('09,'). return. end. /* совпадение с черным списком */
    when 3 then do: run pksave('20,'). return. end. /* отказ по просрочкам */
  end case.
  
  ja = no.
  run sel2 ("ВЫБЕРИТЕ РЕШЕНИЕ ПО АНКЕТЕ КЛИЕНТА :", 
            " 1. Сохранить анкету и рассчитать рейтинг | 2. Не сохранять анкету и выйти | 3. Вернуться к редактированию анкеты ", 
            output v-select).
  
  case v-select:
    when 1 then do: ja = yes. leave. end.
    when 2 then do: ja = no. leave. end.
  end case.
end.

hide all no-pause.

/* сохранение анкеты */

if ja then do:
   find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "ankln" no-lock.
   if not avail pksysc then do:
     message skip " Параметр ANKLN не найден для данного вида кредита !" skip(1)
        view-as alert-box buttons ok title " ОШИБКА ! ".
     return.
   end.

   find first t-anket where t-anket.kritcod = "rnn".
   v-cif = "".

   if t-anket.value1 <> "" then do:
     /* поиск существующего кода клиента - ищем только по нашим кредитам! */
/*     find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.rnn = t-anket.value1 and pkanketa.cif <> "" no-lock no-error.*/
     /* поиск кода клиента по всей клиентской базе */
     find first cif where cif.jss = t-anket.value1 and cif.type = 'P' no-lock no-error.  
     if avail cif then v-cif = cif.cif.
   end.

   /* вычисляемые критерии */
   for each pkkrit where pkkrit.priz = "0" and lookup(s-credtype, pkkrit.credtype) > 0 use-index kritcod no-lock:
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
       run value(pkkrit.proc) in hanket (pkkrit.kritcod).
   end.

   do transaction:
   if not v-isedit then do:
     /* создаем новую анкету */
     find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "ankln" exclusive-lock.
     v-pkankln = pksysc.inval.
     pksysc.inval = pksysc.inval + 1.
     find current pksysc no-lock.

     for each t-anket:
         create pkanketh.
         pkanketh.ln = v-pkankln.
         buffer-copy t-anket except t-anket.ln to pkanketh.
     end.
     release pkanketh.

     create pkanketa.
     assign pkanketa.bank = s-ourbank
            pkanketa.credtype = s-credtype
            pkanketa.ln = v-pkankln
            pkanketa.rdt = today
            pkanketa.rwho = g-ofc
            pkanketa.acc = v-trnum
            pkanketa.crc = v-crcsel.
     
     /*
     if pcoun > 0 then run mv_photos(v-pkankln, pkanketa.rdt).
     */
     
   end.
   else do:
     /* меняем старую анкету */
     for each t-anket:
       find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = v-pkankln and
         pkanketh.kritcod = t-anket.kritcod exclusive-lock no-error.
       if not avail pkanketh then do:
         create pkanketh.
         pkanketh.ln = v-pkankln.
       end.
       buffer-copy t-anket except t-anket.ln to pkanketh.
     end.
     release pkanketh.

     find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = v-pkankln 
          exclusive-lock no-error.
     pkanketa.sts = "".
   end.
   
   pkanketa.cif = v-cif.

   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "rnn" no-lock no-error.
   if avail pkanketh then pkanketa.rnn = pkanketh.value1.
   
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "sik" no-lock no-error.
   if avail pkanketh then pkanketa.sik = pkanketh.value1.
   
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "numpas" no-lock no-error.
   if avail pkanketh then pkanketa.docnum = pkanketh.value1. 
   
   /* собрать полное имя по анкете */
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "lname" no-lock no-error.
   if avail pkanketh then v-name = caps(trim(pkanketh.value1)).
   
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "fname" no-lock no-error.
   if avail pkanketh then do: 
     if v-name <> "" then v-name = v-name + " ".
     v-name = v-name + caps(trim(pkanketh.value1)).
   end.
   
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "mname" no-lock no-error.
   if avail pkanketh then do:
     if v-name <> "" then v-name = v-name + " ".
     v-name = v-name + caps(trim(pkanketh.value1)).
   end.
   
   /* заменить казахские буквы на русские */
   run pkdeffio (input-output v-name).
   pkanketa.name = v-name.
   
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "jobrnn" no-lock no-error.
   if avail pkanketh then pkanketa.jobrnn = pkanketh.value1.
   
   /* переписать результаты проверки в АКИ */
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = v-pkankln and pkanketh.kritcod = "akires" no-lock no-error.
   if avail pkanketh then pkanketa.rescha[2] = pkanketh.value2.
   
   release pkanketa.
   end.

   display g-fname g-mdes g-ofc g-today with frame mainhead.

   s-pkankln = v-pkankln.
   
   /*15/09/2009 galina - добавила для анкеты созаемщика*/
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = v-pkankln and pkanketh.kritcod = "mainln" no-lock no-error.
   if avail pkanketh and trim(pkanketh.value1) <> '' then do transact:
      find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = integer(pkanketh.value1) no-lock no-error.
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "subln" exclusive-lock no-error.
      if not avail pkanketh then do:
         create pkanketh.
         assign pkanketh.bank = s-ourbank
                pkanketh.credtype = s-credtype
                pkanketh.ln = pkanketa.ln
                pkanketh.kritcod = "subln".
      end.
      if trim(pkanketh.value1) <> '' then pkanketh.value1 = pkanketh.value1 + ','.
      pkanketh.value1 = pkanketh.value1 + string(v-pkankln).
      find current pkanketh no-lock no-error.
      
      find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = v-pkankln  exclusive-lock no-error.
      pkanketa.sts = '98'.
      find current pkanketa no-lock no-error.
   end.

   /**/
   
   /* проверка критериев отказа и выдача результата на экран в нужном виде для каждого вида кредита */
  else run value ("pkafterank-" + s-credtype).

end.



