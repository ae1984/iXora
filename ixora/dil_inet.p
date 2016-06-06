/* dil_inet.p
 * MODULE
        Интернет-Оффис
 * DESCRIPTION
	Интернет платежи связанные с конвертацией
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
	13-5
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	06.05.2005 u00121 - Теперь можно выбирать платежи по конкретному РКО, возможность показа всех платежей осталась если выбрать "Все подразделения"
			    а также можно выбирать конкретные виды заявок, и формировать список на конкретную дату, хотя необходимость последнеого сомнительна
			    она оставляется на период тестирования, возможно по поводу даты возникнут какие либу иные предложения со стороны заказчика
			    все изменения произведены на основании СЗ ї 1311 от 21.01.2005 г.
	20.07.2005 u00121 - Добавил вторую дату для отбора конвертаций, теперь можно выбирать за период, по умолчанию первая и вторая даты равны текущему операционному дню
    25.10.2013 yerganat - Добавил колонку Клиент, Сумма, Валюта на браузер. Сумма вычисляется по алгоритму FindRate из класса ConvDocClass.cls.
    29.10.2013 yerganat - Добавил ширину фрейма f1 для корректной компиляции
*/


{classes.i}
{get-dep.i}





def var  documN     like dealing_doc.docno label "Номер документа".
def new shared var dType as integer.

def temp-table t-deal
	field docno           like dealing_doc.docno label "Номер"
	field whn_mod         like dealing_doc.whn_mod  label "Дата"
	field time_mod        like dealing_doc.time_mod label "Время"
    field clientname      as char format "x(15)"  label "Клиент"
    field currency_amount as decimal format "zzz,zzz,zzz,zzz.99" label "Сумма"
    field crc             like crc.crc label "Валюта"
	field jh              like dealing_doc.jh label "Транз-1"
	field jh2             like dealing_doc.jh2 label "Транз-2"
	field doctype         like dealing_doc.doctype
	index i-no docno DESC.

function get_typec returns char (input ctype as integer). /*функция возвращает наименование типа заявки*/
  case ctype:
    when 1 then return("Срочная покупка валюты").
    when 2 then return("Обычная покупка валюты").
    when 3 then return("Срочная продажа валюты").
    when 4 then return("Обычная продажа валюты").
  end case.
end function.

function get_depart returns int. /*функция возвращает код РКО в котором обслуживается клиент*/
  find aaa where aaa.aaa = dealing_doc.tclientaccno no-lock no-error.
  find cif where cif.cif = aaa.cif no-lock no-error.
  if avail cif then return integer(cif.jame) - 1000.
end function.

function get_clientname returns char.
    find first aaa where aaa.aaa = dealing_doc.tclientaccno no-lock no-error.
    if avail aaa then do:
        find first cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then
            return  trim(trim(cif.prefix) + " " + trim(cif.name)).
    end.
    return ''.
end function.


procedure get_amount_currency:
     define output parameter curr_amount as decimal format "zzz,zzz,zzz,zzz.99" init ?.
     define output parameter crc like crc.crc init ?.

     if dealing_doc.jh <> 0 and dealing_doc.jh <> ? then do:
        curr_amount = dealing_doc.v_amount.
        crc = dealing_doc.crc.
        return.
     end.

     find first aaa where aaa.aaa = dealing_doc.tclientaccno no-lock no-error.
     if not avail aaa then
        return.

     find first cif where cif.cif = aaa.cif no-lock no-error.
     if not avail cif then
        return.


     define variable id_viprate as int init 0.
     define variable cur_rate   as decimal format "zzz,zzz.9999".
     define variable CURR       as class CurrencyClass.
     CURR = NEW CurrencyClass(Base).

     /*Вычисляется курс по алгоритму FindRate функции в классе ConvDocClass.cls*/
     if dealing_doc.doctype = 1 or dealing_doc.doctype = 2 then
     do:
        cur_rate = CURR:get-vip-sale-rate(cif.cif,dealing_doc.crc,id_viprate).
        if dealing_doc.doctype = 1 and cur_rate = -1 then cur_rate  = CURR:get-exp-sale-rate(dealing_doc.crc).
        if dealing_doc.doctype = 2 and cur_rate = -1 then cur_rate  = CURR:get-std-sale-rate(dealing_doc.crc).
     end.

     if dealing_doc.doctype = 3 or dealing_doc.doctype = 4 then
     do:
        cur_rate = CURR:get-vip-purch-rate(cif.cif,crc,id_viprate).
        if dealing_doc.doctype = 3 and cur_rate = -1 then cur_rate  = CURR:get-exp-purch-rate(dealing_doc.crc).
        if dealing_doc.doctype = 4 and cur_rate = -1 then cur_rate  = CURR:get-std-purch-rate(dealing_doc.crc).
     end.

     if dealing_doc.doctype = 6 then
     do:
        cur_rate  = CURR:get-vip-cross-rate(cif.cif,CURR:get-crc(dealing_doc.tclientaccno),dealing_doc.crc,id_viprate).
        if cur_rate = -1 then cur_rate  = CURR:get-cross-rate(CURR:get-crc(dealing_doc.tclientaccno),dealing_doc.crc).
     end.

     if dealing_doc.jh = 0 or dealing_doc.jh = ? then
     do:
        /* Определение сумм в валюте в зависимости от валюты ввода суммы на конвертацию */
        if dealing_doc.doctype = 6 then
        do:  /* Для кросс конвертации другой принцип!!! */
           if dealing_doc.crc = dealing_doc.input_crc then
              curr_amount = dealing_doc.f_amount.
           else
              curr_amount = dealing_doc.f_amount * cur_rate.
        end.
        else do:
            if dealing_doc.crc = dealing_doc.input_crc then
                curr_amount = dealing_doc.f_amount.
            else
                curr_amount = dealing_doc.f_amount / cur_rate.
        end.

        crc = CURR:get-crc(dealing_doc.vclientaccno).
      end.

     if VALID-OBJECT(CURR)  then DELETE OBJECT CURR NO-ERROR.
end procedure.

def var vdep as int init 0. /*код выбранного департамента*/
def var vtype as int init 0. /*код выбранного типа заявки*/
def var v-dep as char. /*список департаментов с кодами*/
def var v-dt as date init today label "С". /*дата отбора с*/
def var v-dt2 as date init today label "ПО". /*дата отбора по*/ /*20.07.2005 u00121*/
def var i  as int. /*просто счетчик*/


/*определим  browse для выбора типа заявки*/
def var c-type as char format "x(30)" view-as combo-box LIST-ITEM-PAIRS "Все",0,"Срочная конвертация",1,"Обычная конвертация",2,"Срочная реконвертация",3,"Обычная реконвертация",4 label "Тип".

/*определим browse для выбора департамента*/
def var c-dep as char format "x(30)" view-as combo-box label "Деп.".

/*фрейм отбора*/
def frame f-dep c-dep c-type skip v-dt v-dt with side-label centered row 5 title "Параметры отбора".

/*Формируем список крупных РКО**********************************************************************************************************/


v-dep = "Все подразделения,0". /*По умолчанию будет установлен параметр всех департаментов*/

/*Находим список всех крупных департаментов - коды департаментов перечислены в sysc.chval через запятую */
find last sysc where sysc.sysc = "deprfd" no-lock no-error.
if avail sysc and trim(sysc.chval) <> "" then
do:
	do i = 1 to num-entries (sysc.chval): /*бежим по списку*/
			find last ppoint where ppoint.point = 1 and ppoint.dep = int(entry(i,sysc.chval)) no-lock no-error. /*Найдем департамент в справочнике*/
			if avail ppoint then
			do:
				v-dep = v-dep + "," + replace(ppoint.name,'"',' ') + "," + entry(i,sysc.chval). /*внесем наименование и код департамента в список brows`а департаментов*/
			end.
	end.
end.
else
do:
	find last ppoint where ppoint.point = 1 and ppoint.dep = get-dep(g-ofc,g-today) no-lock no-error.
	if avail ppoint then
		v-dep = v-dep + "," +  replace(ppoint.name,'"',' ') + "," + string(get-dep(g-ofc,g-today)). /*Если список департаментов не найден, внесем в список brows`а департамент офицера запустившего программу*/
end.

assign c-dep:list-item-pairs in frame f-dep = v-dep. /*сохраняем список департаментов в browse*/
enable c-dep with frame f-dep.
/***************************************************************************************************************************************/


on value-changed of c-dep do:
    vdep = int(self:screen-value).
end.

on value-changed of c-type do:
    vtype = int(self:screen-value).
end.

on return of c-dep or return of c-type
do:
    apply "go".
end.

update c-dep  with frame f-dep.
update c-type with frame f-dep.
update v-dt   with frame f-dep.
update v-dt2   with frame f-dep.
/***************************************************************************************************************************************/




/***************************************************************************************************************************************/
def frame f0 t-deal.docno label "Заявка " t-deal.whn_mod with side-labels centered row 5.

define query q_list for t-deal.

    /*Формирование временной таблицы с заявками*********************************************************************************************/
    for each dealing_doc no-lock where dealing_doc.who_cr = 'inbank' and dealing_doc.whn_mod >= v-dt and dealing_doc.whn_mod <= v-dt2 by dealing_doc.docno DESCENDING. /*20.07.2005 u00121*/
    	if dealing_doc.doctype <> vtype and vtype <> 0 then next. /*если тип не равен выбраному и выбранный тип не 0 - то пропускаем документ*/
    /*	if vdep <> get-dep(get_manag(), g-today) and vdep <> 0 then next. /*если департамент офицера обслуживающего счет не равен выбранному департаменту и выбранный департамент не равен 0 то пропускаем документ*/*/
	    if vdep <> get_depart() and vdep <> 0  then next.
		    create t-deal.
			    t-deal.docno =  dealing_doc.docno.
			    t-deal.whn_mod = dealing_doc.whn_mod.
			    t-deal.time_mod = dealing_doc.time_mod.
                t-deal.clientname = get_clientname().
    			t-deal.jh = dealing_doc.jh.
		    	t-deal.jh2 = dealing_doc.jh2.
	    		t-deal.doctype = dealing_doc.doctype.
            run get_amount_currency(output t-deal.currency_amount,output t-deal.crc).
    end.
    /***************************************************************************************************************************************/

define browse b_list query q_list no-lock
  display
		t-deal.docno
		t-deal.whn_mod
		string (t-deal.time_mod, 'HH:MM:SS') label "Время"
        t-deal.clientname
        t-deal.currency_amount
        t-deal.crc
		t-deal.jh
		t-deal.jh2
		get_typec(t-deal.doctype) format 'x(15)' label "Тип документа"
			with title "Список документов" 15 down centered overlay no-row-markers.

define frame f1 b_list with width 110.

on 'return' of b_list in frame f1
do:
  if avail t-deal then
      do:
         readkey pause 0.
         apply lastkey.
         dType = t-deal.doctype.
         hide frame f1.
         run m_valop(t-deal.docno).

         /*Обновление t_deal с изменениями с реальным документом*/
         find first dealing_doc where dealing_doc.docno = t-deal.docno and dealing_doc.doctype = t-deal.doctype no-lock no-error.
         if avail dealing_doc then  do:
            t-deal.jh = dealing_doc.jh.
            t-deal.jh2 = dealing_doc.jh2.
         end. else do:
            delete t-deal no-error.
         end.

         view frame f1.
      end.
end.



on 'value-changed' of b_list in frame f1
do:
    if avail t-deal then do:
        displ  t-deal.docno t-deal.whn_mod with frame f0. pause 0.
    end.
end.


open query q_list
     for each t-deal.


if avail t-deal then do:
   displ t-deal.docno t-deal.whn_mod with frame f0. pause 0.
end.
else do:
    displ with frame f0. pause 0.
end.


enable all with frame f1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

