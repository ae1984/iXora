/* cardcash.p
 * MODULE
        Касса
 * DESCRIPTION
         выплата наличных через кассу по платежным карточкам 
         шаблоны opk0001 для USD,
                 opk0002 для тенге, другие валюты не обслуживаются пока
         комиссия снимается разная в зависимости от вида карточки
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
        07.11.2005 marina - изменение в тарифах,формах.
        18/11/05 marinav -  добавлено примечание по ФИО
        22/11/05 marinav - работа через кассу в пути
        28/11/05 marinav - после 17.00 запрос на кассу в пути
        02/03/06 marinav - время кассы в пути берется из sysc
        01/06/06 u00121  - формирование проводок по кассе в пути для тех департаментов, которые работают только через кассу в пути
*/

/*
*/

{global.i}
{get-dep.i}


/*u00121 01/06/06 Переменные для определения счета кассы в пути *********************************************************************************************************/
def var v-yn 	as log		no-undo.  /*признак запрещения работы через кассу   false - 100100, true - 100200							*/
def var v-err 	as log		no-undo.  /*признак возникновения ошибки если true - ошибка имела место, и говорит о том, что желательно прекратить работу программы	*/
/************************************************************************************************************************************************************************/

def var nxt_doc_nmbr as int.
def var comiss as deci init 0.
def var crc like crc.crc init 1.
def var currname as char init "".
def var currname1 as char init "".
def var vdel as char init "|".
def var v-sel as char.

def var seq_number like ujo.docnum.
def var v-card as char format "x(16)".
def var docsum as char format "x(13)" label "Сумма" init 0.00.
def var docrem as char format "x(50)" init "".
def var docrem1 as char format "x(50)" init "".
def var docrezid as char format "x(3)" label "Резидентство" init "".
def var docsecek as char format "x(3)" label "Сектор экономики" init "".
def var docnaznpl as char format "x(3)" label "Назначение платежа" init "321".
def var doccomsum as char format "x(13)" label "Комиссия   " init 0.00.
def var docall as deci format ">>>,>>>,>>>,>>9.99" label "Итого   " init 0.00.
def var ourbank as logi format 'Да/Нет' init true.
def var v-arp like arp.arp label "Счет кассы в пути:" init "?" no-undo. /*АРП счет кассы в пути*/
def var v-dep like ppoint.depart no-undo. /*код департамента сотрудника*/
def var v-cash as logical init yes.
def var ja as logical format 'Да/Нет' init true.

def var vparam as char init "".
def var vtempl as char init "".
def var m_sub as char.
def var rcode as int.
def var rdes as char.
def new shared var s-jh like jh.jh.
def var v-time as int.

def var minsum as deci init 0.

def temp-table t-cards 
  field cardtype as int
  field ycrc as log extent 2 /* допустимые валюты true/false, если true - есть заранее заданные установки, false - комиссия задается вручную */
  field cardname as char /* Наименование карточки */
  field cardpercent as deci extent 2 /* процент комиссии по каждой валюте */
  field cardminsum as deci extent 2. /* минимальная ставка комиссии по каждой валюте */

DO TRANSACTION on error undo, retry:

for each t-cards. delete t-cards. end.

/* заполнение таблицы карточек */
  create t-cards.
  cardtype = 1.
  ycrc[1] = true.
  ycrc[2] = true.
  cardname = "VISA".
  cardpercent[1] = 0.015.
  cardminsum[1] = 150.
  cardpercent[2] = 0.015.
  cardminsum[2] = 750.

  create t-cards.
  cardtype = 2.
  ycrc[1] = true.
  ycrc[2] = true.
  cardname = "Master Card".
  cardpercent[1] = 0.015.
  cardminsum[1] = 150.
  cardpercent[2] = 0.015.
  cardminsum[2] = 750.
  
  create t-cards.
  cardtype = 3.
  ycrc[1] = false.
  ycrc[2] = true.
  cardname = "Diners Club".
  cardpercent[2] = 0.06.
  cardminsum[2] = 750.

  create t-cards.
  cardtype = 4.
  ycrc[1] = true.
  ycrc[2] = false.
  cardname = "ALTYN".
  cardpercent[1] = 0.006.
  cardminsum[1] = 150.

/*  create t-cards.
  cardtype = 5.
  ycrc[1] = false.
  ycrc[2] = false.
  cardname = "Другие карты".
*/

def query q-cards for t-cards.

def browse b-cards query q-cards 
  displ cardname format "x(30)" label " Платежные карточки "
  with 10 down.

DEF FRAME f-cards
    b-cards help " ENTER - выбор карточки или F4 - возврат в меню"
WITH centered row 5 no-label no-box.

ON RETURN OF b-cards DO:
  CLOSE query q-cards.
  DISABLE ALL WITH FRAME f-cards.
end.

OPEN QUERY q-cards for each t-cards by cardtype.
ENABLE ALL WITH FRAME f-cards.
APPLY "VALUE-CHANGED" TO BROWSE b-cards.
WAIT-FOR RETURN OF b-cards in frame f-cards.

hide frame f-cards.

def frame f-data 
  skip(1)
  "           Документ : " ujo.docnum at 23
  " Транзакция : " at 48 ujo.jh at 62 skip
  "     Дата документа : " ujo.whn at 23 skip
  " ----------------------------------------------------------------------" skip(1)
  " Карты Процес.центра: " ourbank at 23 skip
  "             Валюта : " crc at 23 help " F2 - вызов справочника валют " skip
  "        Номер карты : " v-card at 23 skip
  "              Сумма : " docsum at 23 currname at 38 skip
  "           Комиссия : " doccomsum at 23 currname1 at 38 skip
  "              Итого : " docall at 23 currname1 at 38 skip
  "         Примечание : " docrem at 23 skip
  "      ФИО, N док-та : " docrem1 at 23 skip
  "       Резидентство : " docrezid at 23 help " F2 - вызов справочника " skip
  "   Сектор экономики : " docsecek at 23 help " F2 - вызов справочника " skip
  " Назначение платежа : " docnaznpl at 23 help " F2 - вызов справочника " skip(1)
with no-label centered row 3 title t-cards.cardname.


on help of docrezid in frame f-data do:
    run uni_help1("locat",'*').
end.
on help of docsecek in frame f-data do:
    run uni_help1("secek",'*').
end.


/**u00121 01/06/06**********************************************************/
run get100200arp(g-ofc, crc, output v-yn, output v-arp, output v-err). /*получим признак разрешения работы только через кассу в пути*/
if not v-yn then
do:

            find first sysc where sysc = 'casvod' no-lock no-error.
            if avail sysc and sysc.loval = true then v-cash = no.
            find first sysc where sysc = 'cassof' no-lock no-error.
            if avail sysc then v-time = sysc.inval.

            if v-cash = no or time > v-time then do:
              run sel2 ("Выдача через :", 
                       " 1. Кассу  | 2. Кассу в пути  | 3. Выход ", output v-sel).
              case v-sel:     

                when "1" then  v-cash = yes.
                when "2" then do:    
                    v-dep = get-dep(g-ofc, g-today). /*найдем ID департамента офицера*/
                    find last ppoint where ppoint.depart = v-dep no-lock no-error. /*найдем название департамента офицера*/
                     /*Если касса заблокирована, делаем через кассу в пути*/
                    find last ofc where ofc.ofc = g-ofc no-lock no-error. /*найдем карточку офицера*/
                    v-cash = no.
                end.
                when "3" then  return.
              end case.

            end.
end.
else
	v-cash = no.

/* создание документа */
    nxt_doc_nmbr = next-value (unijou).
    
    create ujo.

    ujo.docnum = string(nxt_doc_nmbr). 
    ujo.whn    = g-today.
    ujo.who    = g-ofc.
    ujo.tim    = time.

    seq_number = ujo.docnum.
    crc = 1. docsum = "". currname = "". docrem = trim(t-cards.cardname). 
    docrezid = "". docsecek = "". doccomsum = "". currname1 = "".

    displ
     ujo.docnum ujo.jh ujo.whn 
     crc docsum currname docrem docrem1 docrezid docsecek docnaznpl doccomsum currname1
    with frame f-data.

    update ourbank
      crc validate((crc = 1 or crc = 2),"Можно работать только с валютами 1 и 2 (тенге и USD)!")
    with frame f-data.

    if v-cash = no then do:
    	find last ofc where ofc.ofc = g-ofc no-lock no-error.
        run FindArp100200(ofc.titcd, crc , output v-arp). /*Находим АРП счет соответсвующий валюте и департаменту офицера*/
        if v-arp = "?" then do:
	message "Счет АРП Касса в пути не найден для департамента " ppoint.name. pause.	undo, return.
        end.
    end.

    ujo.sys = "opk". 
    
    CASE crc :
      WHEN 2 then
        if v-cash = yes then ujo.code = "0001". else ujo.code = "0024".
      WHEN 1 then 
        if v-cash = yes then ujo.code = "0002". else ujo.code = "0023".
      OTHERWISE do:
        message "Можно работать только с валютами 1 и 2!".
        undo, retry.
      end.
   end case.

    find crc where crc.crc = crc.
    currname = crc.code.
    currname1 = crc.code.
    displ currname currname1 with frame f-data.

    update v-card with frame f-data.
    
    /*  отобразить поля для ввода данных шаблона */
do trans:
    update docsum validate(deci(docsum) > 0, "Сумма должна быть больше 0!")
         /*  docnaznpl validate(can-find(codfr where codfr.codfr = "spnpl" and codfr.code = trim(docnaznpl)), "Нет такого кода в справочнике spnpl!")*/
    with frame f-data.

    if t-cards.ycrc[crc] = false or ourbank = true then
      comiss = 0.0.      
    else do:
      comiss = deci(docsum) * t-cards.cardpercent[crc].
      if t-cards.cardminsum[crc] > 0 then do:
        if crc = 1 then
          minsum = t-cards.cardminsum[crc].
        else do:
          minsum = t-cards.cardminsum[crc] / crc.rate[1].
        end.
        comiss = comiss + minsum.
      end.
    end.

/* обрезать десятичные до двух знаков и показать */
    doccomsum = trim(string(comiss,">>>>>>>>>>>9.99")).

    display doccomsum with frame f-data.
    if t-cards.ycrc[crc] = false then do:
      update doccomsum validate(deci(doccomsum) >= 0, "Комиссия не должна быть меньше 0!")
      with frame f-data.
    end.
    docall = deci(docsum) + deci(doccomsum) .

    displ docall with frame f-data.


    if t-cards.cardpercent[crc] > 0 and ourbank = false then
      docrem = docrem + ", комиссия " + trim(string(t-cards.cardpercent[crc] * 100,">9.9")) + "%".
    if t-cards.cardminsum[crc] > 0  and ourbank = false then 
      docrem = docrem + ", + " + string(t-cards.cardminsum[crc]) + "тг".

    if ourbank then do:
       find first card_status where card_status.contract_number = v-card no-lock no-error.
       if avail card_status then  docrem1 = card_status.short_name + ' ' + substr(card_status.pasport,4).
    end.

    displ docrem  with frame f-data.
    update docrem1
           docrezid validate(can-find(codfr where codfr.codfr = "locat" and codfr.code = trim(docrezid)), "Нет такого кода в справочнике locat!")
           docsecek validate(can-find(codfr where codfr.codfr = "secek" and codfr.code = trim(docsecek)), "Нет такого кода в справочнике secek!")
    with frame f-data.
end.

 message "Провести транзакцию ?" update ja.
 if not ja then return.


/*  добавление параметров в таблицу */
    create ujolink.
    ujolink.docnum = seq_number.
    ujolink.parnum = 1.
    ujolink.parval = trim(docsum).

if v-cash = no then do:
    create ujolink.
    ujolink.docnum = seq_number.
    ujolink.parnum = 2.
    ujolink.parval = trim(v-arp).
end.

    create ujolink.
    ujolink.docnum = seq_number.
    ujolink.parnum = 3.
    ujolink.parval = trim(docrem) + ' ' + trim(docrem1).

    create ujolink.
    ujolink.docnum = seq_number.
    ujolink.parnum = 4.
    ujolink.parval = trim(docrezid).

    create ujolink.
    ujolink.docnum = seq_number.
    ujolink.parnum = 5.
    ujolink.parval = trim(docsecek).

    create ujolink.
    ujolink.docnum = seq_number.
    ujolink.parnum = 6.
    ujolink.parval = trim(docnaznpl).

    create ujolink.
    ujolink.docnum = seq_number.
    ujolink.parnum = 7.
    ujolink.parval = trim(doccomsum).

/* создание транзакции */

    find ujo where ujo.docnum eq seq_number exclusive-lock no-error.

    if not (ujo.jh eq 0 or ujo.jh eq ?) then do:
        message "Транзакция уже проведена.".
        undo, retry.
    end.
    if ujo.who ne g-ofc then do:
        message substitute ("Документ принадлежит &1.", ujo.who).
        undo, return.
    end.

/*  сборка параметров шаблона в строку */      
    vparam = "". 
    for each ujolink where ujolink.docnum eq seq_number by ujolink.parnum:
        vparam = vparam + ujolink.parval + vdel.
    end.

    vtempl = ujo.sys + ujo.code.
    m_sub = "ujo".
    s-jh = 0.

    run trxgen (vtempl, vdel, vparam, m_sub, seq_number, output rcode, 
        output rdes, input-output s-jh).

        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.

    ujo.jh = s-jh.

    disp ujo.jh with frame f-data.
                                     
    disable all with frame f-data.
  end.

/* поменять статус на 5, на 6 штампует кассир */
    find jh where jh.jh eq s-jh no-lock no-error.
    if available jh and jh.sts ne 6 then do:
      run trxsts (input s-jh, input 5, output rcode, output rdes).
         if rcode ne 0 then do:
            message rdes.
            undo, return.
         end.
      run chgsts (m_sub, seq_number, "cas").
    end.

/* печать ваучера */
    run uvou_bank ("prit"). /* joe -rdonly !!! prit !!!! в окончательной */

pause.
hide frame f-data.


