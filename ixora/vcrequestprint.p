/* vcrequestprint.p
 * MODULE
        Модуль - Валютный контроль
 * DESCRIPTION
        Описание - Редактирование запросов по ПС,переведенных из другого банка.
 * RUN
        верхнее меню сведений о контракте
 * CALLER
        Список процедур, вызывающих этот файл - vcrequests.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        25.01.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
        23.11.2012 damir - Реализована С.З. от 19.11.2012.
        21.12.2012 damir - Программа работала некорректно,внесены исправления.
*/
{global.i}

def shared var s-contract like vccontrs.contract.
def shared var s-request as char.

def var v-to as char.
def var v-place as char.
def var v-toname as char.
def var v-fil as char.
def var v-date as date.
def var v-ps as char.
def var v-client as char.
def var v-cont as char.
def var v-dt as date.
def var v-part as char.
def var v-partkod as char.
def var v-from as char.
def var v-from1 as char.
def var v-id as char.
def var v-tel as char.
def var v-file as char init "vcrequestprint.htm".

define stream m-out.

find first ofc where ofc.ofc = g-ofc no-lock no-error.

for each vccontrs where vccontrs.contract = s-contract no-lock:
    v-cont = vccontrs.ctnum.

    find first cmp no-lock no-error.
    if avail cmp then v-fil = cmp.name.
    find first cif where cif.cif = vccontrs.cif no-lock no-error.
    if avail cif then v-client = cif.name.

    find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
    if avail vcps then do:
        v-date = vcps.dndate.
        v-ps = vcps.dnnum + string(vcps.num).
        find first vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.info[2] = s-request no-lock no-error.
        if avail vcdocs then do:
            v-place = vcdocs.info[1].
            v-dt = vccontrs.ctdate.
            v-tel = vcdocs.info[5].
            if num-entries(vcdocs.info[3],"|") >= 2 then do:
                v-to = entry(1,vcdocs.info[3],'|').
                v-toname = entry(2,vcdocs.info[3],'|').
            end.
            if num-entries(vcdocs.info[4],"|") >= 2 then do:
                v-from =  entry(1,vcdocs.info[4], '|').
                v-from1 = entry(2,vcdocs.info[4], '|').
            end.
            find first vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
            if avail vcpartner then do:
                v-part = vcpartner.name.
                v-partkod = vcpartner.formasob.
            end.
        end.
    end.
end.

output stream m-out to value(v-file).

{html-title.i &stream = "stream m-out"}

put stream m-out unformatted
    "<P style='font-size:12pt;font:bold' align=right>" v-to "<br>" v-place "<br>" v-toname "<br><br></P>" skip
    "<P>&nbsp;</P>" skip
    "<P style='font-size:12pt'>" v-fil "&nbsp;выражает Вам свое уважение и желает успехов в работе.</P>" skip
    "<P style='font-size:12pt'>В соответствии с пунктом 32 «Правил осуществления экспортно-импортного валютного контроля в
    Республике Казахстан и получения резидентами учетных номеров контрактов по экспорту и импорту» №42 от 24.02.2012 года
    сообщаем Вам, что&nbsp;" v-date "&nbsp;клиенту нашего Банка&nbsp;" v-client "&nbsp;присвоен учетный номер контракта&nbsp;"
    v-ps ".</P>" skip
    "<P style='font-size:12pt'>В связи с этим просим Вас предоставить информацию о движении денег и товара по контракту&nbsp;"
    v-client "&nbsp;" v-cont "&nbsp;от&nbsp;" v-dt "&nbsp;года, заключенному с&nbsp;" v-part "&nbsp;" v-partkod ".</P>" skip
    "<P style='font-size:12pt;font:bold' align=left>С уважением,<br>" v-from "&nbsp;" v-from1 "<br>" v-toname "<br>Исп:&nbsp;"
    trim(ofc.name) "<br>Тел:" v-tel "</P>" skip.

{html-end.i "stream m-out"}

output stream m-out close.

unix silent cptwin value(v-file) winword.



