/* x-ofc.p
 * MODULE
        Управление офицерами Прагмы
 * DESCRIPTION
        редактирование сведений об офицере
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9.1.5.8
 * AUTHOR
        31.12.1999 pragma
 * CHANGES
        04.12.2001 sasco    - printer setup utility (menu #9)
        16.07.2002 nadejda  - история смены Профит-центров
        18.11.2002 nadejda  - записать в список сотрудников по табельному номеру
        18.08.2003 nadejda  - исправлена ошибка в создании новой записи в истории Профит-центров ofcprofit
                              поправлено определение таблицы t-ofc-tn. Нужен индекс по name, тогда можно убрать временную таблицу!
        11.11.2003 nadejda  - добавила вывод только для просмотра даты смены пароля ofc.visadt
        07.03.2004 nadejda  - просмотр и добавление блокировки офицера, проверяется при входе в ПРАГМУ
        07.05.2004 nadejda  - синхронизация на филиалах временной блокировки офицера
        14.05.2004 dpuchkov - просмотр и изменение ограничений офицеров работающих в выходные дни
        20.07.2004 suchkov  - добавлена обработка признака увольнения
        23.08.2004 sasco    - запрос на добавление нового пользователя
        23.08.2004 sasco    - добавлена настройка пакетов доступа
        20.06.2005 sasco    - при добавлении нового сотрудника (в проц. NEWONLY) инициализируется visadt = 01/01/01 чтобы новый пароль запросился
	28.06.2005 u00121   - при блокировке сотрудника более чем на 30 дней, либо при его увольнении удаляются все права сотрудника , после предварительного вопроса конечно же
	30.06.2005 u00121   - изменил количество дней блокировки для удаления прав сотрудника с 30 -> 45
	27.07.2006 u00121   - Добавил возможность установки пароля пользователя равным принятому по умолчанию - кнопка "Пароль"
			    - Добавил возможность синхронизации учетной записи пользователя с филиалами (таблицы ofc, ofchis, _user (по запросу)), 
			    - права не синхронизируется, т.к на каждом филиале они могут быть разными - кнопка "Синхро-вать"
        30.08.06 U00121 	добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        19/07/2010 madiyar - независимое изменение департамента и профит-центра
        24/07/2010 madiyar - вернул как было
*/

{mainhead.i}
{sysc.i}
{yes-no.i}
{comm-txb.i}

  def var v-del as log init false. /*28.06.2005 u00121*/

def new shared var vofc like ofc.ofc.
def new shared var vpoint like ppoin.point.
def var vdep like ppoint.depart.
def var epoint like ppoin.point.
def var edep like ppoint.depart.
def var vprofit like codfr.code.
def var eprofit like codfr.code.
def var v-profitname as char.
def var v-tn like ofc-tn.tn.
def var v-fdt as date.
def var v-tdt as date.
def var v-updfil as logical.
def var v-ourbnk as char.
def var v-fdtfil as date.
def var v-tdtfil as date.
def var v-uvol as logical initial no. /* Признак увольнения */

def var v-accd as logical.

def buffer b-ofcprofit for ofcprofit.

def new shared temp-table t-ofc-tn
  field tn as char
  field name as char
  field ofc as char 
  field profitcn as char
  field fired as logical format "да/ "
  index main is primary name.


for each ofc-tn no-lock:
  create t-ofc-tn.
  buffer-copy ofc-tn to t-ofc-tn.
end.

def new shared var stype as log format '1/0'. def new shared var ptype as log format '1/0'.

v-ourbnk = comm-txb().

/* В этой i-шке пришлось сжать все пробелы */
{head-pty1.i
&start = " on help of vprofit in frame ofc do: run uni_help1('sproftcn', '...'). end. "
&file = "ofc"
&where = " "
&form = " {xofc.f} "
&vseleform = "col 67 row 3 1 col no-label overlay"
&frame = " col 1 row 3 2 col width 66 "
&posupdt = "run ofcupdate."
&postupdate = " if v-updfil then run updfil ('b'). if v-uvol entered and v-uvol then run updfil('u'). if v-uvol entered and not v-uvol then run updfil ('c')."
&flddisp = "ofc.ofc vpoint vdep vprofit v-profitname v-tn ofc.name ofc.addr[1] ofc.addr[2] ofc.expr[1] ofc.tel ofc.regdt v-uvol ofc.tit ofc.expr[5] ofc.lang ofc.indt ofc.bdt ofc.visadt v-fdt v-tdt v-accd"
&newdft = " "
&newonly = " if not yes-no ('Новый сотрудник','Добавить запись для ' + ofc.ofc) then do: delete ofc. next outer. end. run NEWONLY."
&predisp = " run defpredisp."
&delonly = "run delrights."
&index = "ofc"
&prg1 = "other"
&start2 = " "
&end2 = "run fcurrnt." 
&prg2 = "r-ofcpr"
&prg3 = "q-tnlist"
&prg4 = "set-password"
&prg5 = "syncofc"
&prg6 = "other"
&prg7 = "other"
&prg8 = "other"
&prg9 = "other"
&prg10 = "other"
&prg11 = "other"
&prg12 = "other"
&prg13 = "other"
&prg14 = "other"
&prg15 = "other"
&prg16 = "other"
&prg17 = "other"
&other1 = " "
&other2 = "1. Принтер"
&other3 = "2. Обнов.ТН"
&other4 = "Пароль "
&other5 = "Синхро-вать"
&other6 = " "
&other7 = " "
&other8 = " "
&other9 = " "
&other10 = " "
&other11 = " "
&other12 = " "
&other13 = " "
&other14 = " "
&other15 = " "
&other16 = " "
&other17 = " "
}

procedure NEWONLY.
epoint = 0. edep = 0. vprofit = '100'. ofc.visadt = 01/01/01.
end.

procedure defacc.
  if not v-accd then
   ofc.oday[5] = 0.
  else
   ofc.oday[5] = 1.
end procedure.

procedure fcurrnt.
  do transaction: 
    find current ofc exclusive-lock. 
    if stype = true then ofc.mday[1] = 1. 
    else ofc.mday[1] = 0.
    if ptype = true then ofc.mday[2] = 1. 
    else ofc.mday[2] = 0. 
    find current ofc no-lock. 
  end.
end procedure.


procedure delrights.
  do transaction:
    for each sec where sec.ofc = ofc.ofc. delete sec. end.
  end.
end procedure.


procedure defprofitname.
  find codfr where codfr.codfr = "sproftcn" and codfr.code = vprofit no-lock no-error.
  if avail codfr then v-profitname = codfr.name[1].
                 else v-profitname = "".
end procedure.

procedure deftn.
  find ofc-tn where ofc-tn.ofc = ofc.ofc no-lock no-error.
  if avail ofc-tn then v-tn = ofc-tn.tn.
                  else v-tn = "".
end.

procedure defupd.
  if ofc.expr[3] eq "" then do:
    ofc.expr[3] = "prit".
  end.

/* 16/07/02 - nadejda - история смены Профит-центров */

  if vprofit <> eprofit then do:
    find ofcprofit where ofcprofit.ofc = ofc.ofc and ofcprofit.profitcn = vprofit and
         ofcprofit.regdt = g-today exclusive-lock no-error.

    if not avail ofcprofit then do:
      create ofcprofit.
      assign ofcprofit.ofc = ofc.ofc
             ofcprofit.profit = vprofit
             ofcprofit.regdt = g-today
             ofcprofit.tn = v-tn.
    end.
    assign ofcprofit.tn = v-tn
           ofcprofit.tim = time
           ofcprofit.who = g-ofc.
    eprofit = vprofit.

    find current ofcprofit no-lock.

    ofc.titcd = vprofit.

    /* проверка на изменение департамента */
    if substring(vprofit, 1, 1) = get-sysc-cha ("PCRKO") then 
      vdep = integer(substring(vprofit, 2, length(vprofit) - 1)).
    else vdep = 1.
  end.
/* --- end history Profit-center --- */

  if vpoint <> epoint or vdep <> edep then do:
    find ofchis where ofchis.ofc = ofc.ofc and ofchis.regdt = g-today exclusive-lock
         no-error.
    if available ofchis then do :
      ofchis.point = vpoint.
      ofchis.dep = vdep.
    end.
    else do :
      create ofchis.
      assign ofchis.ofc = ofc.ofc
             ofchis.point = vpoint
             ofchis.dep = vdep
             ofchis.regdt = g-today.
    end.

    ofc.regno = vpoint * 1000 + vdep.
    edep = vdep.
  end.


/* 18/11/02 - nadejda - записать в список сотрудников */
  if v-tn <> "" then do:
    find ofc-tn where ofc-tn.tn = v-tn exclusive-lock no-error.
    if avail ofc-tn then do:
      if ofc-tn.ofc = "" then ofc-tn.ofc = ofc.ofc.
      ofc-tn.profitcn = vprofit.
    end.
  end.
  else do:
    find ofc-tn where ofc-tn.ofc = ofc.ofc exclusive-lock no-error.
    if avail ofc-tn then do:
      ofc-tn.profitcn = vprofit.
    end.
  end.

  if avail ofc-tn then do:
    for each ofcprofit where ofcprofit.ofc = ofc.ofc and ofcprofit.tn <> ofc-tn.tn exclusive-lock:
      /* поискать за это число запись с полными данными, если есть - неполную удаляем */
      find b-ofcprofit where b-ofcprofit.ofc = ofcprofit.ofc and b-ofcprofit.regdt = ofcprofit.regdt 
             and b-ofcprofit.profit = ofcprofit.profit and b-ofcprofit.tn = ofc-tn.tn no-lock no-error.
      if avail b-ofcprofit then do:
        delete ofcprofit.
        next.
      end.

      ofcprofit.tn = ofc-tn.tn.
    end.
    release ofcprofit.
  end.
/* ----- */
end.

procedure defvprofit.
  /* 16/07/02 - nadejda - код Профит-центра (для Центрального Офиса - отдел, для РКО - префикс + номер РКО) */
  if vdep > 1 then vprofit = get-sysc-cha ("PCRKO") + string(vdep, '99').
end procedure.

procedure defpredisp.
  vpoint =  integer(ofc.regno / 1000).
  vdep = ofc.regno mod 1000.
  epoint = vpoint.
  edep = vdep. 
  vprofit = ofc.titcd. 
  run defprofitname. 
  eprofit = vprofit. 
  run deftn.

  find last ofcblok where ofcblok.sts = "u" and ofcblok.ofc = ofc.ofc no-lock no-error.
  if avail ofcblok then v-uvol = yes.
                   else v-uvol = no .
  
  find first ofcblok where ofcblok.sts = "b" and ofcblok.ofc = ofc.ofc and 
                          ofcblok.tdt >= g-today no-lock no-error.
  if avail ofcblok then assign v-fdt = ofcblok.fdt v-tdt = ofcblok.tdt.
                   else assign v-fdt = ? v-tdt = ?.
  if ofc.oday[5] = 1 then v-accd = True. else v-accd = False.
end procedure.

procedure defblok.
  find first ofcblok where ofcblok.sts = "b" and ofcblok.ofc = ofc.ofc and 
                          ofcblok.tdt >= g-today no-lock no-error.
  if avail ofcblok and v-fdt = ? and v-tdt = ? then do:
    message " Невозможно удалить период блокировки, измените дату конца периода !".
    pause 100.
    return.
  end.
  
  v-updfil = yes.

  do transaction:
    if avail ofcblok then do: 
      v-fdtfil = ofcblok.fdt.
      v-tdtfil = ofcblok.tdt.
      find current ofcblok exclusive-lock.
    end.
    else do:
      create ofcblok.
      assign ofcblok.ofc = ofc.ofc
             ofcblok.sts = "b"
             ofcblok.rwho = g-ofc
             ofcblok.rdt = today.
      v-fdtfil = v-fdt.
      v-tdtfil = v-tdt.
    end.
    assign ofcblok.fdt = v-fdt
           ofcblok.tdt = v-tdt
           ofcblok.uwho = g-ofc
           ofcblok.udt = today.


    release ofcblok.
  end.
end.


procedure updfil.
  define input parameter pr as character .
  for each comm.txb where comm.txb.consolid no-lock:
      if comm.txb.bank = v-ourbnk and pr = "b" then next.

      if connected ("txb") then disconnect "txb".
      connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
      run x-ofcblk (ofc.ofc, ofc.ofc, v-fdtfil, v-tdtfil, v-fdt, v-tdt, pr, g-ofc, v-del).
  end.
  if connected ("txb") then disconnect "txb".
end.

procedure ofcupdate.
    update vpoint with frame ofc. 
    update vdep with frame ofc.
    if vdep <> edep and vdep > 1 then run defvprofit. 
                                 else update vprofit with frame ofc.
    run defupd. 
    run defprofitname. 

    display vdep vprofit v-profitname with frame ofc.

ofc.tit = "user".
ofc.lang = "rr".

    update v-tn with frame ofc.
    update ofc.name  ofc.addr[1] ofc.addr[2] ofc.expr[1] ofc.tel ofc.regdt ofc.indt ofc.tit ofc.lang ofc.expr[5] ofc.bdt with frame ofc.
    update v-uvol with frame ofc.

    v-updfil = no. 
    
    update v-fdt with frame ofc. 
       

    if v-fdt entered or v-fdt <> ? then update v-tdt with frame ofc.

    /*28.06.2005 u00121********************************************************************************************************************************************************************/    
    v-del = false.
    if  v-uvol and not v-del then
    do:
		if yes-no ( "Удаление прав для " + trim(ofc.ofc), "Сотрудник уволен. БЛОКИРОВАТЬ ПРАВА ДОСТУПА?") then 
		do:
			v-del = true.	
		end.
    end.
   /*28.06.2005 u00121********************************************************************************************************************************************************************/


    if v-fdt entered or v-tdt entered then 
    do:
	 /*28.06.2005 u00121********************************************************************************************************************************************************************/
	if (v-tdt - v-fdt) >= 45 and not v-uvol and not v-del then
	do:
		if yes-no ( "Удаление прав для " + trim(ofc.ofc), "Период блокировки равен " + string(v-tdt - v-fdt) + " дн., необходимо блокировать все права. БЛОКИРОВАТЬ?") then 
		do:
				v-del = true.
		end.
	end. 
   	 /*28.06.2005 u00121********************************************************************************************************************************************************************/
	run defblok. 
   end.

    update v-accd with frame ofc. 
    if v-accd entered then run defacc.
end.
