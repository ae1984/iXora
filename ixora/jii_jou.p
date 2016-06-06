/* jii_jou.p
 * MODULE
        Название Программного Модуля
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
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        21.04.10 marinav - добавилось третье поле примечания
*/

        /** jii_jou.p
        (D) KONTS -- (K) ARP **/
        /*01.10.02 nadejda - наименование клиента заменено на форма собств + наименование
        19/01/06 marinav   - определение реквизитов плательщика
        20/01/06 marinav   - Запрос чека только если arp - это касса в пути
        09.02.2006 marinav - добавлена возможность оплаты за филиалы
        10/06/08 marinav   - закоментарен запрос чековой книжки
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
        22/11/2011 evseev  - переход на ИИН/БИН.
        19.07.2012 damir   - поправил сохранение данных по удост.личности в поле joudoc.passp,добавил v_doc_num.
        */

{mainhead.i}
{yes-no.i}
{chbin.i}

define buffer xcif for cif.
define buffer xaaa for aaa.

define new shared variable s-jh like jh.jh.
define new shared variable s-aaa like aaa.aaa.

define shared buffer bcrc for crc.
define shared buffer ccrc for crc.

define shared variable v_doc like joudoc.docnum.
define shared variable loccrc1 as character format "x(3)".
define shared variable loccrc2 as character format "x(3)".
define shared variable f-code  like crc.code.
define shared variable t-code  like crc.code.

define variable nat_crc like crc.crc no-undo.
define variable amt_out as character no-undo.

define variable rcode   as integer no-undo.
define variable rdes    as character no-undo.
define variable vdel    as character initial "^" no-undo.
define variable vparam  as character no-undo.
define variable templ   as character no-undo.
define variable jparr   as character format "x(20)" no-undo.

define variable card_dt as character no-undo.
define variable vvalue  as character no-undo.
define variable fname   as character no-undo.
define variable lname   as character no-undo.
define variable crccode like crc.code no-undo.
define variable cardsts as character no-undo.
define variable cardexp as character no-undo.

define variable pbal     like jl.dam no-undo.   /*Full balance*/
define variable pavl     like jl.dam no-undo.   /*Available balance*/
define variable phbal    like jl.dam no-undo.   /*Hold balance*/
define variable pfbal    like jl.dam no-undo.   /*Float balance*/
define variable pcrline  like jl.dam no-undo.   /*Credit line*/
define variable pcrlused like jl.dam no-undo.   /*Used credit line*/
define variable pooo     like aaa.aaa no-undo.

def var v-badd1  as char no-undo.
def var v-badd2  as char no-undo.
def var v-badd3  as char no-undo.
def var id       as inte no-undo.
def var v-plat   as char init 'u' no-undo.
def var v-fio    like cif-heir.fio no-undo.
def var v-idcard like cif-heir.idcard no-undo.
def var v-jssh   like cif-heir.jss no-undo.
def var v-ser as char init "" no-undo.

define variable d_amt     like joudoc.dramt no-undo.
define variable c_amt     like joudoc.cramt no-undo.
define variable com_amt   like joudoc.comamt no-undo.
define variable m_buy     as decimal no-undo.
define variable m_sell    as decimal no-undo.
define variable s-rnn     as char no-undo.
define variable v_doc_num like joudoc.passp.

def temp-table wupl  no-undo
    field id    as   inte
    field upl   as   inte
    field badd1 as   char
    field badd2 as   char
    field badd3 as   char
    field finday like uplcif.finday
index main is primary unique upl.

def temp-table wheir no-undo
    field id     as   inte
    field fio    as   char
    field idcard as   char
    field jss    as   char
    field ratio  as   char
index main fio.

{mframe.i "shared"}

define frame f_cus
    joudoc.info   label "ПОЛУЧАТЕЛЬ " skip
    v_doc_num     label "ПАСПОРТ    " skip
    joudoc.perkod label "ПЕРС.КОД   "
    with row 8 centered overlay side-labels.

on help of joudoc.info in frame f_cus do:
   id = 0.
   run choise_upl.
   if v-badd1 <> '' then joudoc.info   = v-badd1.
   if v-badd2 <> '' then v_doc_num  = v-badd2.
   displ joudoc.info v_doc_num joudoc.perkod with frame f_cus.
end.

define frame f_heir
    joudoc.info   label "НАСЛЕДНИК  " skip
    v_doc_num     label "ПАСПОРТ    " skip
    joudoc.perkod label "ПЕРС.КОД   "
    with row 8 centered overlay side-labels.
on help of joudoc.info in frame f_heir do:
   id = 0.
   run choise_heir.
   if v-fio    <> '' then joudoc.info   = v-fio.
   if v-idcard <> '' then v_doc_num  = v-idcard.
   displ joudoc.info v_doc_num joudoc.perkod with frame f_heir.
end.

/* 09.02.2006 marinav */
on help of dname_3 in frame f_main do:
           run ord_help(d_cif, output s-rnn).
           dname_3 = s-rnn.
           displ dname_3 with frame f_main.
end.
/* 09.02.2006 marinav */

DO transaction:

find joudoc where joudoc.docnum eq v_doc exclusive-lock.
joudoc.chk   = 0.
d_atl = "СЧТ-ОСТ".  c_atl = "АРП-ОСТ".
d_lab = "ИСП-ОСТ".
joudoc.info = "". v_doc_num = "".  joudoc.perkod = "".
display joudoc.dracc joudoc.cracc joudoc.chk d_atl c_atl d_lab
    with frame f_main.

L_1:
repeat on endkey undo, return:
    repeat on endkey undo, return:
        message "ВВЕДИТЕ НОМЕР СЧЕТА.".
        update joudoc.dracc /*format "x(10)"*/ with frame f_main.
        find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
            if not available aaa then do:
                message "Счет не существует.".
                pause 3.
                undo, retry.
            end.
        leave.
    end.

    s-aaa = joudoc.dracc.

/*Ограничение доступа пользователей*/
find last aaa where aaa.aaa = s-aaa no-lock no-error.
if avail aaa then do:
  find last cif where cif.cif = aaa.cif no-lock no-error.
  if avail cif then do:

  find last cifsec where cifsec.cif = cif.cif no-lock no-error.
  if avail cifsec then
  do:
     find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
     if not avail cifsec then
     do:
        message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
        create ciflog.
        assign
          ciflog.ofc = g-ofc
          ciflog.jdt = today
          ciflog.cif = cif.cif
          ciflog.sectime = time
          ciflog.menu = "2.1 Журнал операций".
          return.
     end.
     else
       do:
          create ciflogu.
          assign
            ciflogu.ofc = g-ofc
            ciflogu.jdt = today
            ciflogu.sectime = time
            ciflogu.cif = cif.cif
            ciflogu.menu = "2.1 Журнал операций".
       end.
  end.
end.
end.
/*Ограничение доступа пользователей*/

    run aaa-aas.

    if aaa.sta = "C" then do:
        message "Счет закрыт.".
        pause 3.
        undo, retry.
    end.

    find first aas where aas.aaa = s-aaa and aas.sic = 'SP' no-lock no-error.
        if available aas then do:
            message "ОСТАНОВКА ПЛАТЕЖЕЙ!".
            pause 3.
            undo,retry.
        end.

    run aaa-bal777 (input aaa.aaa, output pbal, output pavl, output phbal,
        output pfbal, output pcrline, output pcrlused, output pooo).

    find cif of aaa no-lock.
    d_cif = cif.cif.
    dname_1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),  1, 38).
    dname_2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)), 39, 38).
    if v-bin then dname_3 = cif.bin. else dname_3 = cif.jss .
    d_avail = string (pbal, "z,zzz,zzz,zzz,zzz.99").
    d_izm   = string (pavl, "z,zzz,zzz,zzz,zzz.99").
/* 06.02.2006 marinav */
    update dname_3 with frame f_main.
    display d_cif dname_1 dname_2 dname_3 d_avail d_izm with frame f_main.
    color display input dname_1 dname_2 dname_3 with frame f_main.
    if v-bin then do:
       if trim(dname_3) ne trim(cif.bin) then joudoc.rescha[1] = dname_3.
    end. else do:
       if trim(dname_3) ne trim(cif.jss) then joudoc.rescha[1] = dname_3.
    end.
/* 06.02.2006 marinav */

    joudoc.drcur = aaa.crc.
    find crc where crc.crc eq aaa.crc no-lock no-error.
    f-code = crc.code.
    display joudoc.drcur crc.des with frame f_main.

    repeat on endkey undo, return:
        message "ВВЕДИТЕ НОМЕР АРП КАРТОЧКИ ".
        update joudoc.cracc /*format "x(10)"*/ with frame f_main.

        find arp where arp.arp eq joudoc.cracc no-lock no-error.
            if not available arp then do:
                message "АРП не найден.".
                pause 3.
                undo, retry.
            end.
        leave.
    end.

    find gl where gl.gl eq arp.gl no-lock no-error.
    if gl.type eq "A" or gl.type eq "E" then
        c_avail = string (arp.dam[1] - arp.cam[1], "z,zzz,zzz,zzz,zzz.99").
    else
        c_avail = string (arp.cam[1] - arp.dam[1], "z,zzz,zzz,zzz,zzz.99").

    cname_1 = arp.des.
    display cname_1 c_avail with frame f_main.
    color display input cname_1 with frame f_main.

    joudoc.crcur = arp.crc.
    find bcrc where bcrc.crc eq arp.crc no-lock no-error.
    t-code = bcrc.code.
    display joudoc.crcur bcrc.des with frame f_main.

    if f-code ne t-code then do:
        display loccrc1 loccrc2 f-code t-code with frame f_main.
        hide message.
    end.
    else do:
        joudoc.brate = 0.
        joudoc.srate = 0.
        joudoc.bn = 0.
        joudoc.sn = 0.

        display "" @ loccrc1 "" @ loccrc2 joudoc.bn joudoc.sn
            "" @ f-code "" @ t-code joudoc.brate joudoc.srate with frame f_main.
        hide message.
    end.


    if (cif.type eq 'B' or cif.type eq 'M' or cif.type eq 'N') and gl.gl = 100200 then repeat
        on endkey undo, next L_1:
     /*
        update joudoc.chk with frame f_main.

        update v-ser label "Cерия чековой книжки" format "x(2)" with frame zxz side-labels centered row 8.
        v-ser = lower(v-ser).
        if lookup(substr(v-ser, 1 ,1),"q,a,z,w,s,x,e,d,c,r,f,v,t,g,b,y,h,n,u,j,m,i,k,l,o,p") <> 0 then do:
           message "Необходимо ввести серию русскими буквами"  view-as alert-box title "".  undo,retry.
        end.

        find first gram where gram.nono le joudoc.chk and
                            gram.lidzno ge joudoc.chk and gram.ser <> "" and gram.ser = v-ser  no-lock no-error.
            if not available gram then
        find first gram where gram.nono le joudoc.chk and
                            gram.lidzno ge joudoc.chk and gram.ser = ""  no-lock no-error.

            if not available gram then do:
                message "Чека с таким номером нет в системе. " +
                    " Введите другой номер.".
                undo, retry.
            end.
            if gram.anuatz eq "*" then do:
                message "Чековая книжка аннулирована.".
                undo, retry.
            end.
            if gram.cif eq "" then do:
                message "Указанная чековая книжка еще не продана.".
                undo, retry.
            end.

        if gram.cif ne "" then do:
            find cif where cif.cif eq gram.cif no-lock no-error.
                if not available cif then do:
                    message substitute ("Клиент с кодом &1 не найден.",
                        gram.cif).
                    undo, retry.
                end.

            if d_cif ne gram.cif then do:
                message substitute ("Чек N&1 клиенту не принадлежит",
                    joudoc.chk).
                undo, retry.
            end.
        end.
     */
        leave.

    end.
    else
    if cif.type eq "P" then do:
        joudoc.info   = trim(trim(cif.prefix) + " " + trim(cif.name)).
        if v-bin then joudoc.perkod = cif.bin. else joudoc.perkod = cif.jss.
        if num-entries(trim(cif.pss),",") > 1 or num-entries(trim(cif.pss)," ") <= 1 then joudoc.passp = trim(cif.pss).
        else joudoc.passp = entry(1,trim(cif.pss)," ") + "," + substring(trim(cif.pss),index(trim(cif.pss)," "), length(cif.pss)).
    end.


    /** MAKS…JUMA SUMMA **/
    repeat on endkey undo, next L_1:
        update joudoc.dramt with frame f_main.
        if joudoc.dramt eq 0 then update joudoc.cramt with frame f_main.
        if joudoc.dramt eq 0 and joudoc.cramt eq 0 then undo, retry.
        else do:
            if joudoc.dramt ne 0 then joudoc.bas_amt = "D".
            else if joudoc.cramt ne 0 then joudoc.bas_amt = "C".

            if joudoc.drcur eq joudoc.crcur then do:
                if joudoc.dramt ne 0 then joudoc.cramt = joudoc.dramt.
                else if joudoc.cramt ne 0 then joudoc.dramt = joudoc.cramt.

                display joudoc.dramt joudoc.cramt with frame f_main.
               /* update joudoc.remark with frame f_main.

                leave.*/
            end.
            else do:
                if joudoc.bas_amt eq "D" then do:
                    d_amt = joudoc.dramt.
                    c_amt = 0.
                end.
                if joudoc.bas_amt eq "C" then do:
                    d_amt = 0.
                    c_amt = joudoc.cramt.
                end.

                run conv (input joudoc.drcur, input joudoc.crcur, input false,
                    input false, input-output d_amt, input-output c_amt,
                    output joudoc.brate, output joudoc.srate,
                    output joudoc.bn, output joudoc.sn,
                    output m_buy, output m_sell).

                display joudoc.brate joudoc.srate joudoc.bn joudoc.sn
                    with frame f_main.

                run jii_tmpl
                    (input joudoc.bas_amt, output vparam, output templ).

                if joudoc.bas_amt eq "D" then do:
                    run trxsim("", templ, vdel, vparam, 5, output rcode,
                        output rdes, output jparr).
                        if rcode ne 0 then do:
                            message rdes.
                            pause 3.
                            undo, return.
                        end.

                    joudoc.cramt = decimal (jparr).
                    display joudoc.cramt with frame f_main.
                end.
                if joudoc.bas_amt eq "C" then do:
                    run trxsim("", templ, vdel, vparam, 3, output rcode,
                        output rdes, output jparr).
                        if rcode ne 0 then do:
                            message rdes.
                            pause 3.
                            undo, return.
                        end.

                    joudoc.dramt = decimal (jparr).
                    display joudoc.dramt with frame f_main.
                end.
                display joudoc.dramt joudoc.cramt with frame f_main.
            end.
            pause 0.

            if cif.type ne "P" then do:
                update joudoc.info v_doc_num joudoc.perkod with frame f_cus.
                if num-entries(trim(v_doc_num),",") > 1 or num-entries(trim(v_doc_num)," ") <= 1 then joudoc.passp = trim(v_doc_num).
                else joudoc.passp = entry(1,trim(v_doc_num)," ") + "," + substring(trim(v_doc_num),index(trim(v_doc_num)," "), length(v_doc_num)).
            end.
            else do:
	            /* 16.09.2004 saltanat Выбор плательщика (владелец либо уполн.лицо) */
	            if yes-no ('', 'Плательщиком является владелец счета ?') then do:
                    display joudoc.info v_doc_num joudoc.perkod with frame f_cus.
                    update v_doc_num with frame f_cus.
                    if num-entries(trim(v_doc_num),",") > 1 or num-entries(trim(v_doc_num)," ") <= 1 then joudoc.passp = trim(v_doc_num).
                    else joudoc.passp = entry(1,trim(v_doc_num)," ") + "," + substring(trim(v_doc_num),index(trim(v_doc_num)," "), length(v_doc_num)).
	            end.
                    else do:
                    repeat on endkey undo, retry:
	                    message 'u - Уполномоченное лицо, n - Наследник'.
        	            update v-plat no-label skip
                              with frame fplat centered row 5 title ' Задайте параметр '.
                	    hide frame fplat.
	                    if v-plat ne 'u' and v-plat ne 'n' then displ 'Выберите U или N !'.
        	            else leave.
                    end.
                    if v-plat eq 'u' then do:
	                    find first uplcif where uplcif.cif = d_cif and uplcif.dop = s-aaa no-error.
        	            if avail uplcif then do:
			            display joudoc.info v_doc_num joudoc.perkod with frame f_cus.
		        	    message (' Укажите данные уполномоченного лица ! ').
			            joudoc.info   = ''.
				        v_doc_num  = ''.
			            update joudoc.info v_doc_num with frame f_cus.
                        if num-entries(trim(v_doc_num),",") > 1 or num-entries(trim(v_doc_num)," ") <= 1 then joudoc.passp = trim(v_doc_num).
                        else joudoc.passp = entry(1,trim(v_doc_num)," ") + "," + substring(trim(v_doc_num),index(trim(v_doc_num)," "), length(v_doc_num)).
			            hide frame f_cus.
			    end.
        	            else do:
				    message skip " У клиента нет уполномоченных лиц ! " skip(1) view-as
				    alert-box button ok title "".
	                    undo, retry.
        	            end. /* uplcif */
                    end.
                    else do:
	                    find first cif-heir where cif-heir.cif = d_cif and cif-heir.aaa = s-aaa no-error.
        	            if avail cif-heir then do:
			            display joudoc.info v_doc_num joudoc.perkod with frame f_heir.
		        	    message (' Укажите данные наследника ! ').
			            joudoc.info   = ''.
				        v_doc_num  = ''.
			            update joudoc.info v_doc_num with frame f_heir.
                        if num-entries(trim(v_doc_num),",") > 1 or num-entries(trim(v_doc_num)," ") <= 1 then joudoc.passp = trim(v_doc_num).
                        else joudoc.passp = entry(1,trim(v_doc_num)," ") + "," + substring(trim(v_doc_num),index(trim(v_doc_num)," "), length(v_doc_num)).
			            hide frame f_heir.
			    end.
        	            else do:
				    message skip " У клиента нет наследников ! " skip(1) view-as
				    alert-box button ok title "".
	                    undo, retry.
        	            end. /* cif-heir */
                    end.
                    end.
            end. /* frame f_cus */

            if joudoc.chk ne 0 then do:
                joudoc.remark[1] = "Выплата по чеку Nr." + string (joudoc.chk).
                display joudoc.remark[1] with frame f_main.
                display joudoc.rescha[3] with frame f_main.
            end.
            else if gl.gl = 100200 then joudoc.remark[1] = "Выплата.".
            update joudoc.remark with frame f_main.
            update joudoc.rescha[3] with frame f_main.
        end.

        leave.
    end.

    leave.
end.

procedure choise_upl.  /* 16.09.2004 saltanat - процедура выбора уполномоченного лица */
for each wupl.
delete wupl.
end.
v-badd1 = ''. v-badd2 = ''. v-badd3 = ''.

upper:
for each uplcif where uplcif.cif = d_cif and dop = s-aaa.
  for each wupl.
  if (wupl.badd1 = uplcif.badd[1]) and (wupl.badd2 = uplcif.badd[2]) and
     (wupl.badd3 = uplcif.badd[3]) then next upper.
  end.
  if uplcif.badd[1] <> '' then do:
  id = id + 1.
  create wupl.
  assign wupl.id = id
            wupl.upl    = uplcif.upl
            wupl.badd1  = uplcif.badd[1]
            wupl.badd2  = uplcif.badd[2]
            wupl.badd3  = uplcif.badd[3]
            wupl.finday = uplcif.finday.
  end.
end.
find first wupl no-error.
if not avail wupl then do:
   message skip " У клиента нет уполномоченных лиц ! " skip(1) view-as
   alert-box button ok title "".
   return.
end.
   {itemlist.i
    &file = "wupl"
    &frame = "row 6 centered scroll 1 12 down overlay "
    &where = " true "
    &flddisp = " wupl.id    label 'N' format 'zz9'
                 wupl.badd1 label 'Ф.И.О.' format 'x(20)'
                 wupl.badd2 label 'Паспорт.данные'
                 wupl.badd3 label 'Кем/Когда выдан' format 'x(20)'
                 wupl.finday label 'Дата окон.дов.'
               "
    &chkey = "id"
    &chtype = "integer"
    &index  = "main"
    &end = "if keyfunction(lastkey) eq 'end-error' then return."
   }
  if wupl.finday >= g-today then do:
  v-badd1  = wupl.badd1.
  v-badd2  = wupl.badd2.
  v-badd3  = wupl.badd3.
  end.
  else
  Message ('У уполномоченного лица истек срок доверенности ! ').
end procedure.

procedure choise_heir.
for each wheir.
delete wheir.
end.
v-fio = ''. v-idcard = ''. v-jssh = ''.
upper:
for each cif-heir where cif-heir.cif = d_cif.
  for each wheir.
  if (wheir.fio    = cif-heir.fio) and
     (wheir.idcard = cif-heir.idcard) and
     (wheir.jss    = cif-heir.jss) then next upper.
  end.
  if cif-heir.fio <> '' then do:
  id = id + 1.
  create wheir.
  assign wheir.id     = id
         wheir.fio    = cif-heir.fio
         wheir.idcard = cif-heir.idcard
         wheir.jss    = cif-heir.jss
         wheir.ratio  = cif-heir.ratio.
  end.
end.
find first wheir no-error.
if not avail wheir then do:
   message skip " У клиента нет наследников ! " skip(1) view-as
   alert-box button ok title "".
   return.
end.
   {itemlist.i
    &file = "wheir"
    &frame = "row 6 centered scroll 1 12 down overlay "
    &where = " true "
    &flddisp = " wheir.id    label 'N'
                 wheir.fio label 'Ф.И.О.' format 'x(20)'
                 wheir.idcard label 'Удостоверение' format 'x(12)'
                 wheir.jss label 'РНН' format 'x(12)'
                 wheir.ratio label 'Доля' format 'x(10)'
               "
    &chkey = "id"
    &chtype = "integer"
    &index  = "main"
    &end = "if keyfunction(lastkey) eq 'end-error' then return."
   }
  v-fio    = wheir.fio.
  v-idcard = wheir.idcard.
  v-jssh   = wheir.jss.
end procedure.


run jou_com.
if keyfunction (lastkey) eq "end-error" then undo, return.

leave.
END.
