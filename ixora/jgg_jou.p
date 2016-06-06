/* jgg_jou.p
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
 * CHANGES
        16.09.2004 saltanat - Добавила выборку заполнения для клиента и уполном. лиц в фрейме f_cus
        17.09.2004 saltanat - Включила откат если нет уполном.лиц
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        22.12.2004 saltanat - В выбор плательщика добавила наследника.
        22.06.2010 marinav - убрана комиссия за обнал
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
        13/09/2011 dmitriy - при коде комиссии 302, исключил возможность проставления суммы комиссии
        22/11/2011 evseev - переход на ИИН/БИН.
*/

/** jgg_jou.p
    (D) KONTS->0 -- (K) KASE **/
/* 01.10.02 nadejda - наименование клиента заменено на форма собств + наименование */

{mainhead.i}
{yes-no.i}
{chbin.i}

define buffer xaaa for aaa.

define new shared variable s-jh like jh.jh.
define new shared variable s-aaa like aaa.aaa.

define new shared variable com_rec as recid.

define shared buffer bcrc for crc.
define shared buffer ccrc for crc.

define shared variable v_doc like joudoc.docnum.
define shared variable loccrc1 as character format "x(3)".
define shared variable loccrc2 as character format "x(3)".
define shared variable f-code  like crc.code.
define shared variable t-code  like crc.code.

define variable nat_crc like crc.crc.

define variable banka   as character.
define variable vsum    like jl.dam.
define variable vgl     like gl.gl.
define variable vdes    as character.

define variable rcode   as integer.
define variable rdes    as character.
define variable vdel    as character initial "^".
define variable vparam  as character.
define variable templ   as character.
define variable jparr   as character format "x(20)".

define variable card_dt as character.
define variable vvalue  as character.
define variable fname   as character.
define variable lname   as character.
define variable crccode like crc.code.
define variable cardsts as character.
define variable cardexp as character.

define variable pbal     like jl.dam.   /*Full balance*/
define variable pavl     like jl.dam.   /*Available balance*/
define variable phbal    like jl.dam.   /*Hold balance*/
define variable pfbal    like jl.dam.   /*Float balance*/
define variable pcrline  like jl.dam.   /*Credit line*/
define variable pcrlused like jl.dam.   /*Used credit line*/
define variable pooo     like aaa.aaa.

define variable a   as decimal format "zzz,zzz,zzz,zzz.99" .
define variable s   as decimal format "zzz,zzz,zzz,zzz.99".
define variable ds  as decimal.
define variable dsnal  as decimal.
define variable eps as decimal decimals 4 initial 0.001.
define variable hh  as decimal decimals 4 format "-zzz,zzz.9999".

define variable v-jss as character extent 10.
define variable v-dt  as date.
define variable i     as integer.
define variable rin   as char.
define variable dd    as integer.
define variable mm    as integer.
define variable gg    as integer.

define variable d_amt   like joudoc.dramt.
define variable c_amt   like joudoc.cramt.
define variable com_amt like joudoc.comamt.
define variable m_buy   as decimal.
define variable m_sell  as decimal.

def var v-nal like trxbal.dam .
def var v9-nal like trxbal.dam .
def var dramt like joudoc.dramt.

define variable kurica as character.

def var v-badd1 as char.
def var v-badd2 as char.
def var v-badd3 as char.
def var id as inte.
def var v-plat   as char init 'u'.
def var v-fio    like cif-heir.fio.
def var v-idcard like cif-heir.idcard.
def var v-jssh   like cif-heir.jss.

def temp-table wupl
    field id    as   inte
    field upl   as   inte
    field badd1 as   char
    field badd2 as   char
    field badd3 as   char
    field finday like uplcif.finday
index main is primary unique upl.

def temp-table wheir
    field id     as   inte
    field fio    as   char
    field idcard as   char
    field jss    as   char
    field ratio  as   char
index main fio.

{mframe.i "shared"}

define frame f_cus
    joudoc.info   label "ПОЛУЧАТЕЛЬ " skip
    joudoc.passp  label "ПАСПОРТ    " skip
    joudoc.perkod label "ПЕРС.КОД   "
    with row 8 centered overlay side-labels.
on help of joudoc.info in frame f_cus do:
   id = 0.
   run choise_upl.
   if v-badd1 <> '' then joudoc.info   = v-badd1.
   if v-badd2 <> '' then joudoc.passp  = v-badd2.
   displ joudoc.info joudoc.passp joudoc.perkod with frame f_cus.
end.

define frame f_heir
    joudoc.info   label "НАСЛЕДНИК  " skip
    joudoc.passp  label "ПАСПОРТ    " skip
    joudoc.perkod label "ПЕРС.КОД   "
    with row 8 centered overlay side-labels.
on help of joudoc.info in frame f_heir do:
   id = 0.
   run choise_heir.
   if v-fio    <> '' then joudoc.info   = v-fio.
   if v-idcard <> '' then joudoc.passp  = v-idcard.
   displ joudoc.info joudoc.passp joudoc.perkod with frame f_heir.
end.

on help of joudoc.comcode in frame f_main do:
   run jcom_hlp.
end.

find crc where crc.crc = 1 no-lock.
nat_crc = crc.crc.


DO transaction:

find joudoc where joudoc.docnum eq v_doc exclusive-lock.
joudoc.cracc = "".
d_atl = "СЧТ-ОСТ".  c_atl = "".
d_lab = "ИСП-ОСТ".
c_cif = "".
cname_1 = "". cname_2 = "". cname_3 = "".
c_avail = "".
joudoc.info = "". joudoc.passp = "".  joudoc.perkod = "".
display joudoc.cracc c_cif cname_1 cname_2 cname_3 c_avail d_atl c_atl d_lab
    with frame f_main.

L_1:
repeat on endkey undo, return:
    repeat on endkey undo, return:
        message "ВВЕДИТЕ НОМЕР СЧЕТА.".
        update joudoc.dracc /*format "x(10)"*/ with frame f_main.
        find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
            if not available aaa then do:
                message "Счет не найден.".
                pause 3.
                undo, retry.
            end.
        leave.
    end.

    s-aaa = joudoc.dracc.
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
    if v-bin then dname_3 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)), 77, 17) + " (" + cif.bin + ")".
    else dname_3 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)), 77, 17) + " (" + cif.jss + ")".
    d_avail = string (pbal, "z,zzz,zzz,zzz,zzz.99").
    d_izm   = string (pavl, "z,zzz,zzz,zzz,zzz.99").
    joudoc.dramt = pavl.
    display d_cif dname_1 dname_2 dname_3 d_avail joudoc.dramt d_izm
        with frame f_main.
    color display input dname_1 dname_2 dname_3 with frame f_main.

    if (cif.type eq 'B' or cif.type eq 'M' or cif.type eq 'N') then
        update joudoc.chk with frame f_main.
    else if cif.type eq "P" then do:
        v-jss[1] = cif.jel.
        do i = 2 to 10:
            if index(v-jss[i - 1],'&') >  0 then do:
                v-jss[i] = substring(v-jss[i - 1],index(v-jss[i - 1],'&') + 1).
                v-jss[i - 1] =
                    substring(v-jss[i - 1],1,index(v-jss[i - 1],'&') - 1).
            end.
            else v-jss[i] = ''.
        end.
        if index(v-jss[10],'&') > 0 then
            v-jss[10] = substring(v-jss[10],1,index(v-jss[10],'&') - 1).
        rin = v-jss[1].
        i = index(rin,'/').
            if i = 0 then v-dt = ?.
            else do:
                dd = integer(trim(substring(rin,1,i - 1))).
                rin = substring(rin,i + 1).
                i = index(rin,'/').
                mm = integer(trim(substring(rin,1,i - 1))).
                rin = substring(rin,i + 1).
                gg = integer(trim(substring(rin,1))).
                v-dt = date(mm,dd,gg).
            end.
        joudoc.info   = trim(trim(cif.prefix) + " " + trim(cif.name)).
        if v-bin then joudoc.perkod = cif.bin. else joudoc.perkod = cif.jss.
        joudoc.passp  = v-jss[2] + ", " + string (v-dt, "99/99/9999").
            if joudoc.passp eq ? then joudoc.passp = "".
    end.

    joudoc.drcur = aaa.crc.
    find crc where crc.crc eq aaa.crc no-lock no-error.
    f-code = crc.code.
    display joudoc.drcur crc.des with frame f_main.

    repeat on endkey undo, next L_1:
        message "  F2 - ПОМОЩЬ  ".
        update joudoc.crcur with frame f_main.
        leave.
    end.

    find bcrc where bcrc.crc eq joudoc.crcur no-lock no-error.
    t-code = bcrc.code.
    display bcrc.des with frame f_main.

    if f-code ne t-code then do:
        /*joudoc.brate = crc.rate[4].
        joudoc.srate = bcrc.rate[3].
        joudoc.bn = crc.rate[9].
        joudoc.sn = bcrc.rate[9].*/

        display loccrc1 loccrc2 /*crc.rate[9] bcrc.rate[9]*/ f-code t-code
            /*joudoc.brate joudoc.srate*/ with frame f_main.
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

    leave.
end.

pause 0.

if cif.type ne "P" then
           update joudoc.info joudoc.passp joudoc.perkod with frame f_cus.
else do:
	   /* 16.09.2004 saltanat Выбор плательщика (владелец либо уполн.лицо либо наследник) */
	   if yes-no ('', 'Плательщиком является владелец счета ?') then do:
	      display joudoc.info joudoc.passp joudoc.perkod with frame f_cus.
	      update  joudoc.passp with frame f_cus.
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
			            display joudoc.info joudoc.passp joudoc.perkod with frame f_cus.
		        	    message (' Укажите данные уполномоченного лица ! ').
			            joudoc.info   = ''.
				    joudoc.passp  = ''.
			            update joudoc.info joudoc.passp with frame f_cus.
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
			            display joudoc.info joudoc.passp joudoc.perkod with frame f_heir.
		        	    message (' Укажите данные наследника ! ').
			            joudoc.info   = ''.
				    joudoc.passp  = ''.
			            update joudoc.info joudoc.passp with frame f_heir.
			            hide frame f_heir.
			    end.
        	            else do:
				    message skip " У клиента нет наследников ! " skip(1) view-as
				    alert-box button ok title "".
	                    undo, retry.
        	            end. /* cif-heir */
                    end.
	   end.
end.

find jouset where jouset.drnum eq joudoc.dracctype and
    jouset.crnum eq joudoc.cracctype and jouset.fname eq g-fname
    no-lock no-error.

    if ambiguous jouset then do:
        if joudoc.crcur eq nat_crc then
            find jouset where jouset.drnum eq joudoc.dracctype and
                jouset.crnum eq joudoc.cracctype and jouset.natcur
                and jouset.fname eq g-fname no-lock.
        else if joudoc.crcur ne nat_crc then
            find jouset where jouset.drnum eq joudoc.dracctype and
                jouset.crnum eq joudoc.cracctype and not jouset.natcur
                and jouset.fname eq g-fname no-lock.
    end.

    find first joucom where joucom.fname eq jouset.fname and joucom.comtype eq
        jouset.proc and joucom.comnat eq jouset.natcur no-lock no-error.

        if not available joucom then do:
            joudoc.comcode = "".
            joudoc.comamt = 0.
            joudoc.comacctype = "".
            joudoc.comacc = "".
            joudoc.comcur = 0.

            if joudoc.drcur eq joudoc.crcur then joudoc.cramt = joudoc.dramt.
            else do:
                joudoc.bas_amt = "D".

                if joudoc.bas_amt eq "D" then do:
                    d_amt = joudoc.dramt.
                    c_amt = 0.
                end.
                else if joudoc.bas_amt eq "C" then do:
                    d_amt = 0.
                    c_amt = joudoc.cramt.
                end.

                run conv (input joudoc.drcur, input joudoc.crcur, input false,
                    input true, input-output d_amt, input-output c_amt,
                    output joudoc.brate, output joudoc.srate,
                    output joudoc.bn, output joudoc.sn,
                    output m_buy, output m_sell).

                display joudoc.brate joudoc.srate joudoc.bn joudoc.sn
                    with frame f_main.

                run jgg_tmpl (input joudoc.bas_amt,
                    output vparam, output templ).

                run trxsim("", templ, vdel, vparam, 5, output rcode,
                    output rdes, output jparr).
                    if rcode ne 0 then do:
                        message rdes.
                        pause 3.
                        undo, return.
                    end.

                joudoc.cramt = decimal (jparr).
            end.

            display joudoc.comcode joudoc.comamt joudoc.comacc joudoc.comcur
                joudoc.cramt with frame f_main.
            return.
        end.

com_rec = recid (jouset).

find joucom where joucom.fname eq jouset.fname and joucom.comtype eq
    jouset.proc and joucom.comnat eq jouset.natcur and joucom.comprim
    no-lock no-error.
    if not available joucom then
        message "УКАЖИТЕ КОД КОМИССИИ,  F2 - ПОМОЩЬ  ".
    else joudoc.comcode = joucom.comcode.

update joudoc.comcode with frame f_main.
find joucom where joucom.fname eq jouset.fname and joucom.comtype eq
    jouset.proc and joucom.comnat eq jouset.natcur and joucom.comcode eq
    joudoc.comcode no-lock no-error.

    if not available joucom then do:
        message "КОД КОМИССИИ НЕ РАЗРЕШЕН...  F2 - ПОМОЩЬ ".
        pause 3.
        undo, retry.
    end.

find tarif2 where tarif2.num + tarif2.kod eq joudoc.comcode and tarif2.stat = 'r'.
display joudoc.comcode tarif2.pakalp with frame f_main.

find first jouset where jouset.proc eq "jcc_jou" no-lock no-error.
joudoc.comacctype = jouset.drnum.
joudoc.comacc     = joudoc.dracc.
joudoc.comcur     = joudoc.drcur.
find jounum where jounum.num eq joudoc.comacctype no-lock.
com_com = joudoc.comacctype + "." + jounum.des.

find ccrc where ccrc.crc eq joudoc.comcur no-lock no-error.
display com_com joudoc.comacc joudoc.comcur ccrc.des with frame f_main.

a = joudoc.dramt.
s = a.

v-nal  = 0.
v9-nal = 0.
dramt = joudoc.dramt.

find first trxbal where trxbal.sub = "cif" and trxbal.crc eq joudoc.drcur
    and trxbal.acc = joudoc.dracc and trxbal.lev = 9 no-lock no-error.

if available trxbal then do:
    v-nal = trxbal.cam - trxbal.dam .
    v9-nal = trxbal.cam - trxbal.dam .
end.

if joudoc.dramt > v-nal then do on error undo,retry :
    Message "Обналичивается сумма:" +
            string(joudoc.dramt - v-nal,"z,zzz,zzz,zzz,zz9.99-") .

    run aaa-bal777 (input aaa.aaa, output pbal, output pavl, output phbal,
            output pfbal, output pcrline, output pcrlused, output pooo).


    find sub-cod where sub-cod.sub eq "cln" and sub-cod.acc eq d_cif and                                    sub-cod.d-cod eq "clnsts" no-lock no-error.
    if not available sub-cod then do:
       message substitute (
          "Клиент &1 в справ. clnsts не найден. " +
          "Код комиссии за обналичивание - 409.", d_cif).
       kurica = "409".
    end.
    else if sub-cod.ccode eq "msc" then do:
       if sub-cod.ccode eq "msc" then message substitute (
          "Клиент &1 в справ. clnsts не определен. " +                                 "Код комиссии за обналичивание - 409.", d_cif).
       kurica = "409".
    end.
    else if (sub-cod.ccode eq "0") then kurica = "409".
    else if (sub-cod.ccode eq "1") then kurica = "419".

    REPEAT:

    run perev (input aaa.aaa, input joudoc.comcode, input s, input joudoc.drcur,
        input joudoc.comcur, "", output ds, output vgl, output vdes).
   /*
    run perev (input aaa.aaa, input kurica, input v-nal, input joudoc.drcur,
         input joudoc.comcur, "", output dsnal, output vgl, output vdes).
   */
    dsnal = 0.
    hh = a - s - ds - dsnal .
        if hh > (- eps) and hh < eps then leave.
    s = s + hh.
    v-nal = s - /*amt9 */ v9-nal .
    /*disp hh a s ds dsnal v-nal.
        pause.*/
    END.

    joudoc.comamt = ds.
    joudoc.nalamt = dsnal.
    joudoc.dramt = joudoc.dramt - joudoc.comamt - joudoc.nalamt.

    display joudoc.dramt joudoc.comamt joudoc.nalamt with frame f_main.
    if joudoc.comcode <> '302' then
    update joudoc.comamt with frame f_main.
end.
else do:
    REPEAT:

    run perev (input aaa.aaa, input joudoc.comcode, input s, input joudoc.drcur,
        input joudoc.comcur, "", output ds, output vgl, output vdes).
    hh = a - s - ds.
        if hh > (- eps) and hh < eps then leave.
    s = s + hh.
    END.

    joudoc.comamt = ds.
    joudoc.nalamt = 0.
    joudoc.dramt = joudoc.dramt - joudoc.comamt.
    display joudoc.dramt joudoc.comamt with frame f_main.
    if joudoc.comcode <> '302' then
    update joudoc.comamt with frame f_main.
end.

/*update joudoc.comamt with frame f_main.*/

if joudoc.drcur ne joudoc.crcur then do:
    joudoc.bas_amt = "D".
    joudoc.dramt = dramt - joudoc.comamt - joudoc.nalamt.

    if joudoc.bas_amt eq "D" then do:
        d_amt = joudoc.dramt.
        c_amt = 0.
    end.
    else if joudoc.bas_amt eq "C" then do:
        d_amt = 0.
        c_amt = joudoc.cramt.
    end.

    run conv (input joudoc.drcur, input joudoc.crcur, input false,
        input true, input-output d_amt, input-output c_amt,
        output joudoc.brate, output joudoc.srate,
        output joudoc.bn, output joudoc.sn, output m_buy, output m_sell).

    display joudoc.brate joudoc.srate joudoc.bn joudoc.sn
        with frame f_main.

    run jgg_tmpl (input joudoc.bas_amt, output vparam, output templ).

    run trxsim("", templ, vdel, vparam, 5, output rcode,
        output rdes, output jparr).
        if rcode ne 0 then do:
            message rdes.
            pause 3.
            undo, return.
            end.

    joudoc.cramt = decimal (jparr).
    display joudoc.cramt joudoc.dramt with frame f_main.
end.
else do:
    joudoc.cramt = dramt - joudoc.comamt - joudoc.nalamt.
    joudoc.dramt = dramt - joudoc.comamt - joudoc.nalamt.
    display joudoc.cramt joudoc.dramt with frame f_main.
end.

if joudoc.cramt lt 0 then undo, return.

END.

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
    &flddisp = " wheir.id     label 'N'
                 wheir.fio    label 'Ф.И.О.' format 'x(20)'
                 wheir.idcard label 'Удостоверение' format 'x(12)'
                 wheir.jss    label 'РНН' format 'x(12)'
                 wheir.ratio  label 'Доля' format 'x(10)'
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
