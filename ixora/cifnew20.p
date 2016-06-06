/* cifnew20.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        открытие 20-тизначного счета соотвествующего 9-тизначному
 * RUN
        верхнее меню "ОткС20"
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.2
 * BASES
        BANK COMM
 * AUTHOR
        15/04/2009 galina
 * CHANGES
        16/04/2009 galina - записываем в поле ааа20 переменную s-accont
        17/04/2009 galina - убрала проверку на старые депозиты
        01.06.2009 galina - добавила исключения по тарифам для 20-тизначных счетов юр.лиц.
        01.07.2009 galina - исправила коментарии в исключениях по тарифам для 20-тизначных счетов  
                            еще раз исправила коментарии в исключениях по тарифам для 20-тизначных счетов  
        23.07.2009 galina - исправила коментарии в исключениях по тарифам для 20-тизначных счетов                      
        17.08.2009 galina - определяем тип клиента (Юр или Физ лицо) по типу в cif и признаку sub-cod

*/
{global.i}
{u-2-w.i}
{sysc.i}
def stream v-out.
def var v-ofile as char.
def var v-ifile as char.
def var v-clientname as char.
def var v-name as char.
def var v-iik as char.
def var v-str as char.
def var v-rnn as char.
def var v-sys as char.


def var v-aaacif like aaa.aaa.
def shared var s-cif like cif.cif.    /*!!!!!*/
def new shared var s-aaa like aaa.aaa.
def new shared var s-lgr like lgr.lgr.
def new shared  Variable V-sel As Integer FORMAT "9" init 1.
def  new shared var in_command as decimal .
def  new shared  var v-rate as decimal.

def var v-log as log init no.

def var ans as log.
def var v-lgr like lgr.lgr.
def var vans as log.
def new shared  variable st_period as integer initial 30.
def new shared var opt as cha format "x(1)".
def new shared var s-okcancel as logical initial False.   

def var v-lgrwrong as log init false.
def var s-accont as char.
def var l-ShowContract as logical.

def new shared var v-aaa9 as char.
def var v-ur as logical.

function month-des returns char (num as date):
   case month(num):
       when  1 then return "января".
       when  2 then return "февраля".
       when  3 then return "марта".
       when  4 then return "апреля".
       when  5 then return "мая".
       when  6 then return "июня".
       when  7 then return "июля".
       when  8 then return "августа".
       when  9 then return "сентября".
       when 10 then return "октября".
       when 11 then return "ноября".
       when 12 then return "декабря".
   end case. 
end function.



{print-dolg.i}

disp  'Ввдите номер 9-значного счета ' v-aaa9 format "x(9)"
      with no-label row 18 frame uniques centered overlay top-only.
      update v-aaa9 with frame uniques.
      
hide frame uniques.      
      
find aaa where aaa.cif = s-cif and aaa.aaa = v-aaa9 and aaa.sta <> 'C' no-lock no-error. 
if not avail aaa then do:
   message "Не найден 9-тизначный счет клиента!" view-as alert-box.
   return.
end.

if aaa.aaa20 <> "" then do:
   message "Соотвествующий 20-тизначный счет уже открыт!" view-as alert-box.
   return.
end.


{comm-txb.i}

s-lgr = aaa.lgr.

find lgr where lgr.lgr eq s-lgr.
find led where led.led eq lgr.led.

/*if led.led = "TDA" then do:
  message "20-тизначный счет пока только для текущих счетов!~nДепозиты будут открываться позднее" view-as alert-box.
  return.
end.*/

find crc where crc.crc = lgr.crc no-lock.

/*if lookup(lgr.lgr,"A28,A29,A30,A13,A14,A15") <> 0 then do:
   message "С 01.06.08 ЗАПРЕЩЕНО открывать депозит по данной группе".
   pause.
   return.
end.*/

/* 01/07/02 - nadejda
проверка соответствия признаков клиента признаку группы открываемого счета - требуется обязательное совпадение
lgr.tlev по справочнику lgrsts с признаками клиента по справочникам clnsts, secek, ecdivis
  tlev = 1: юрлицо, у клиента должно быть юрлицо, сектор 1-8, отрасль 1-97
  tlev = 2: физлицо, у клиента должно быть физлицо, сектор 9, отрасль 98
  tlev = 3: ЧП, у клиента должно быть юрлицо, сектор 9, отрасль 98
*/

if lgr.tlev = 0 then do:
   message "Не указан тип клиентов для этой группы счетов. Нельзя открыть счет.".
   pause.
   v-lgrwrong = true.
end.

find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif and sub-cod.d-cod = "clnsts" no-lock no-error.
if not avail sub-cod or sub-cod.ccode = "msc" then do:
   message "Неверное значение статуса клиента - msc. Нельзя открыть счет.".
   pause.
   v-lgrwrong = true.
end.

if not ((lgr.tlev = 1 and int(sub-cod.ccode) = 0) /* юр лицо */ or 
       (lgr.tlev = 2 and int(sub-cod.ccode) = 1) /* физ лицо */ or 
       (lgr.tlev = 3 and int(sub-cod.ccode) = 0)) /* ЧП */ then do:
    message "Статус клиента не соответствует типу клиентов для этой группы счетов. Нельзя открыть счет.".
    pause.
    v-lgrwrong = true.
end.

find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif and sub-cod.d-cod = "secek" no-lock no-error.
if not avail sub-cod or sub-cod.ccode = "msc" then do:
   message "Неверное значение сектора экономики клиента - msc. Нельзя открыть счет.".
   pause.
   v-lgrwrong = true.
end.

if not ((lgr.tlev = 1 and 
       ((int(sub-cod.ccode) >= 1 and int(sub-cod.ccode) <= 8)) or 
       (trim(sub-cod.ccode) = "A")) /* юр лицо */ or 
       (lgr.tlev = 2 and int(sub-cod.ccode) = 9) /* физ лицо */ or 
       (lgr.tlev = 3 and int(sub-cod.ccode) = 9) /* ЧП */ ) then do:
   message "Сектор экономики клиента не соответствует типу клиентов для этой группы счетов. Нельзя открыть счет.".
   pause.
   v-lgrwrong = true.
end.

find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif and sub-cod.d-cod = "ecdivis" no-lock no-error.
if not avail sub-cod or sub-cod.ccode = "msc" then do:
   message "Неверное значение отрасли экономики клиента - msc. Нельзя открыть счет.".
   pause.
   v-lgrwrong = true.
end.

if not ((lgr.tlev = 1 and 
       ((int(sub-cod.ccode) >= 1 and int(sub-cod.ccode) <= 97) or 
       (int(sub-cod.ccode) = 99))) /* юр лицо */ or 
       (lgr.tlev = 2 and int(sub-cod.ccode) = 98) /* физ лицо */ or 
       (lgr.tlev = 3 and int(sub-cod.ccode) = 98) /* ЧП */ ) then do:
   message "Отрасль экономики клиента не соответствует типу клиентов для этой группы счетов. Нельзя открыть счет.".
   pause.
   v-lgrwrong = true.
end.
  
if v-lgrwrong then return.
 /* конец проверки соответствия признаков */


 /* проверка допустимости валюты */
if crc.sts = 9 then do:
   message "Невозможно открыть счет, валюта " + crc.code + " закрыта.".
   pause.
   return.
end.

if keyfunction(lastkey) eq "GO" or keyfunction(lastkey) eq "RETURN" then do transaction on error undo,return:
  {mesg.i 1808} update ans.
  if ans eq false then return.
  
  if lgr.nxt eq 0 then do:
     {mesg.i 1812} update s-aaa.
  end.
  else do:
     run acc_gen(input lgr.gl,lgr.crc,s-cif,'',true,output s-aaa).                 
  end.
  if s-aaa eq "" then do:
     message "Account number generation error.".             
     pause 5.
     return.
  end.  
  s-accont  =  s-aaa.      
  
  if lgr.feensf = 8 then  do:
    def button  btn11  label "Да, я хочу автоматически пролонгировать счет".
    def button  btn22  label "Нет, пролонгировать счет не надо ".
    def button  btn33  label "Выход".
    def var prz2 as integer.
    def frame frame2
    skip(1) btn11 btn22 btn33 with centered title "Выберите опцию:" row 5 .

    on choose of btn11,btn22,btn33 do:
      if self:label = "Да, я хочу автоматически пролонгировать счет" then prz2 = 1.
      else
      if self:label = "Нет, пролонгировать счет не надо " then prz2 = 2.
      else prz2 = 3.
    end.
   
    enable all with frame frame2.
    wait-for choose of btn11, btn22, btn33.
    if prz2 = 3 then return.
    hide  frame frame2.
    
    if prz2 = 1  or prz2 = 2 then do:
      /*добавил проверку иначе вылетает из прагмы */
      find last sub-cod where sub-cod.acc = s-aaa and sub-cod.sub = 'CIF' exclusive-lock no-error.
      if not avail sub-cod then
      /*добавил проверку иначе вылетает из прагмы */
             create sub-cod.
             sub-cod.acc = s-aaa.
             sub-cod.sub = 'CIF'. sub-cod.d-cod = 'prlng'. 
             if prz2 = 1 then sub-cod.ccod = 'yes'. else  sub-cod.ccod = 'no'.
             sub-cod.rdt = g-today.
    end.
  end. 
/*end.  */
  

  /*find last aaa where aaa.cif = s-cif no-lock no-error.
  if avail  aaa then l-ShowContract = False. else l-ShowContract = True.*/

   run  cif-new2.
   find aaa where aaa.aaa = s-aaa  exclusive-lock no-error.
   if avail  aaa and aaa.cif = "" then  delete aaa.
   if avail  aaa and lgr.led = "TDA" and aaa.lstmdt = ? then delete aaa. 

   if aaa.lgr = '246' then do:
      run add-exc(s-aaa, s-cif, "193").
      run add-exc(s-aaa, s-cif, "180").
      run add-exc(s-aaa, s-cif, "450").
      run add-exc(s-aaa, s-cif, "429").
      run add-exc(s-aaa, s-cif, "181").
      run add-exc(s-aaa, s-cif, "419").
      run doggcvp.
   end.
/*проставляем исключения в тарификаторе*/
  find first aaa where aaa.aaa = s-accont and aaa.regdt >= 05/18/2009 and aaa.sta <> "C" no-lock no-error.
  if avail aaa then do:  
    if length(aaa.aaa) = 20 and not (aaa.lgr begins "4") then do: 
       find sub-cod where sub-cod.sub eq "cln" and sub-cod.d-cod eq "clnsts" and sub-cod.acc eq aaa.cif no-lock no-error.
	   if not available sub-cod then do:
	     find first cif where cif.cif = aaa.cif no-lock no-error.
	     if avail cif then do: 
	       if cif.type = 'B' then v-ur = true.
	       else v-ur = false.
	     end.  
	   end.  
	   if avail sub-cod then do:
	     if sub-cod.ccode = "0" then v-ur = true.    
	     else v-ur = false.    
	   end.   
		
      if v-ur then do:
      /*find first cif where cif.cif = aaa.cif no-lock no-error.
      if avail cif then do:    
        if cif.type = 'B' then do:*/
          if aaa.crc = 1 then do:
             run add-exc1(aaa.aaa,aaa.cif,'154').
             run add-exc1(aaa.aaa,aaa.cif,'104').
          end.  
          else do:
             run add-exc1(aaa.aaa,aaa.cif,'153').
             run add-exc1(aaa.aaa,aaa.cif,'192').
          end.
       /* end.        
      end.*/
      end.
    end.
  end.
/**/  
   find aaa where aaa.cif = s-cif and aaa.aaa = v-aaa9 and aaa.sta <> 'C' exclusive-lock no-error. 
   if avail aaa then do:
     aaa.aaa20 = s-accont.
     find current aaa no-lock no-error. 
   end.
end.  


procedure add-exc.
  def input parameter p-aaa as char.
  def input parameter p-cif as char.
  def input parameter p-kod as char.

  find tarif2 where tarif2.str5 = p-kod and tarif2.stat = 'r' no-lock no-error.
  if avail tarif2 then do:

    find tarifex where tarifex.cif  = p-cif and tarifex.str5 = p-kod and tarifex.stat = 'r' exclusive-lock no-error.
    if not avail tarifex then do:
      create tarifex.
      assign tarifex.cif    = p-cif
             tarifex.kont   = tarif2.kont
             tarifex.pakalp = "Выплаты по пенсиям и пособиям"
             tarifex.str5   = p-kod
             tarifex.crc    = 1
             tarifex.who    = "M" + g-ofc 
             tarifex.whn    = g-today
             tarifex.stat   = 'r'
             tarifex.wtim   = time
             tarifex.ost  = tarif2.ost
             tarifex.proc = tarif2.proc
             tarifex.max1 = tarif2.max1
             tarifex.min1 = tarif2.min1.
      run tarifexhis_update.
    end.

    find tarifex2 where tarifex2.aaa = p-aaa  and tarifex2.cif  = p-cif and tarifex2.str5 = p-kod and tarifex2.stat = 'r' exclusive-lock no-error.
    if not avail tarifex2 then do:
      create tarifex2.
      assign tarifex2.aaa    = p-aaa
             tarifex2.cif    = p-cif
             tarifex2.kont   = tarif2.kont
             tarifex2.pakalp = "Выплаты по пенсиям и пособиям"
             tarifex2.str5   = p-kod
             tarifex2.crc    = 1
             tarifex2.who    = "M" + g-ofc 
             tarifex2.whn    = g-today
             tarifex2.stat   = 'r'
             tarifex2.wtim   = time.
      run tarifex2his_update.
    end.
    assign tarifex2.ost  = 0
           tarifex2.proc = 0
           tarifex2.max1 = 0
           tarifex2.min1 = 0.
             
    release tarifex.
  end.
end procedure.

/*для текущих счетов юр.лиц*/
procedure add-exc1.
  def input parameter p-aaa as char.
  def input parameter p-cif as char.
  def input parameter p-kod as char.

  find tarif2 where tarif2.str5 = p-kod and tarif2.stat = 'r' no-lock no-error.
  if avail tarif2 then do:

    find tarifex where tarifex.cif  = p-cif and tarifex.str5 = p-kod and tarifex.stat = 'r' exclusive-lock no-error.
    if not avail tarifex then do:
      create tarifex.
      assign tarifex.cif    = p-cif
             tarifex.kont   = tarif2.kont
             /*tarifex.pakalp = "Комиссия aaa20"*/
             tarifex.str5   = p-kod
             tarifex.crc    = 1
             tarifex.who    = "M" + g-ofc 
             tarifex.whn    = g-today
             tarifex.stat   = 'r'
             tarifex.wtim   = time
             tarifex.ost  = tarif2.ost
             tarifex.proc = tarif2.proc
             tarifex.max1 = tarif2.max1
             tarifex.min1 = tarif2.min1.
     case p-kod:
       when '192' then tarifex.pakalp = 'За вед.сч ЮЛ без НДС валюта'.
       when '104' then tarifex.pakalp = 'За вед.сч ЮЛ б/НДС KZT с обор.'.
       when '153' then tarifex.pakalp = 'Вед сч при отс денег в теч мес'.
       when '154' then tarifex.pakalp = 'Вед сч при отс денег в теч мес'.
     end.
      
             
      run tarifexhis_update.
    end.

    find tarifex2 where tarifex2.aaa = p-aaa  and tarifex2.cif  = p-cif and tarifex2.str5 = p-kod and tarifex2.stat = 'r' exclusive-lock no-error.
    if not avail tarifex2 then do:
      create tarifex2.
      assign tarifex2.aaa    = p-aaa
             tarifex2.cif    = p-cif
             tarifex2.kont   = tarif2.kont
             /*tarifex2.pakalp = "Комиссия aaa20"*/
             tarifex2.str5   = p-kod
             tarifex2.crc    = 1
             tarifex2.who    = "M" + g-ofc 
             tarifex2.whn    = g-today
             tarifex2.stat   = 'r'
             tarifex2.wtim   = time.
    
      case p-kod:
        when '192' then tarifex2.pakalp = 'За вед.сч ЮЛ без НДС валюта'.
        when '104' then tarifex2.pakalp = 'За вед.сч ЮЛ б/НДС KZT с обор.'.
        when '153' then tarifex2.pakalp = 'Вед сч при отс денег в теч мес'.
        when '154' then tarifex2.pakalp = 'Вед сч при отс денег в теч мес'.
      end.
      run tarifex2his_update.
    end.
    assign tarifex2.ost  = 0
           tarifex2.proc = 0
           tarifex2.max1 = 0
           tarifex2.min1 = 0.
             
    release tarifex.
  end.
end procedure.
/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifexhis_update.
create tarifexhis.
buffer-copy tarifex to tarifexhis.
end procedure.

procedure tarifex2his_update.
create tarifex2his.
buffer-copy tarifex2 to tarifex2his.
end procedure.
