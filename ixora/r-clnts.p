/* r-clnts.p
 * MODULE
        Отчет по клиентам банка
 * DESCRIPTION
        Автоматизированный отчет по ю/л
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
 * MENU
        8.12.3.7
 * AUTHOR
        18.02.2004 isaev
 * CHANGES
        24.02.2004 tsoy Добавил 2 поля
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
 */

{html_stuff.i}
{get-dep.i}
{mainhead.i}

def var v-type as int label "Тип Клиентов" initial 3
            view-as radio-set vertical
            radio-buttons "Активные", 1, "Закрытые", 2, "Все", 3.


def frame fr_main
            v-type skip
            with width 60 row 15 side-labels centered title "Параметры отчета" .
on "return" of v-type in frame fr_main apply "go" to frame fr_main.

view frame fr_main.
   update v-type with frame fr_main.
hide frame fr_main.


function is_credit returns logical (ciff as char, dt as date):
    find first lon where lon.cif = ciff no-lock no-error.
    if not avail lon then
        return no.

    def var cr as decimal.
    run atl-dat(input lon.lon, input dt, output cr).
    if cr > 0 then return yes.
    else return no.
end.



function is_rasch returns logical (ciff as char):
    for each aaa where aaa.cif = ciff
                 and aaa.sta <> 'c'
                 use-index cif no-lock:
        find first lgr where lgr.lgr = aaa.lgr
                       and lgr.led = 'dda' no-lock no-error.
        if avail lgr then
            return yes.
    end.
    return no.
end.


function is_dep returns logical (ciff as char):
    for each aaa where aaa.cif = ciff
                 and aaa.sta ne 'c'
                 use-index cif no-lock:
        find first lgr where lgr.lgr = aaa.lgr
                       and (lgr.led = 'tda' or lgr.led = 'cda') no-lock no-error.
        if avail lgr then
            return yes.
    end.
    return no.
end.



def temp-table clnts
    field clnts_cif like cif.cif
    field clnts_name like cif.name
    field clnts_oper as char init ""
    field clnts_contact as char
    field clnts_addr as char
    field clnts_depart as int
    field clnts_iscred as logical init no
    field clnts_isaccnt as logical init no
    field clnts_isdep as logical init no
    field clnts_head as char init ""
    field clnts_phone1 as char init ""
    field clnts_phone2 as char init ""
    .

def var cif_dep as int.
def var my_dep as int.
def var deprt as char.
def var i as int.

def var v-chief as char.

def frame process_frame skip(1) "Создается отчет..." skip(1)
              with width 40 row 15 side-labels centered.


/* BEGIN */

view frame process_frame.
my_dep = get-dep(g-ofc, g-today).

for each cif no-lock:
    accumulate cif.cif (count).

    if (accum count cif.cif) > 10000 then leave.

    find first sub-cod where sub-cod.sub = 'cln'
                       and sub-cod.acc = cif.cif
                       and sub-cod.d-cod = 'clnsts'
                       and sub-cod.ccode = '0'
                       use-index dcod no-lock no-error.
    if not avail sub-cod then next.

    find first sub-cod where  sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and
          sub-cod.d-cod matches '*clnc*' no-lock no-error.
    if available sub-cod then  v-chief = sub-cod.rcode. 

    
    create clnts.
    assign
        clnts_cif = cif.cif
        clnts_name = cif.prefix + ' ' + cif.name
        clnts_addr = cif.addr[1]
        clnts_iscred = is_credit(cif.cif, g-today)
        clnts_isaccnt = is_rasch(cif.cif)
        clnts_isdep = is_dep(cif.cif)
        clnts_head    = v-chief.
        clnts_phone1  = cif.tel.
        clnts_phone2  = cif.tlx.
        .


    case v-type:
         when 1 then do:
                  /* если нет ни одной услуги оказываемой Банком то не нужен */
                  if not (clnts_iscred or clnts_isaccnt or clnts_isdep) then do:
                      delete clnts.
                      next.
                  end.
         end.            
         when 2 then do:
                 if clnts_iscred or clnts_isaccnt or clnts_isdep then do:
                      delete clnts.
                      next.
                  end.
         end.        
    end case.


    /* департамент клиента */
    clnts_depart = integer(cif.jame) modulo 1000 no-error.

    /* если ofc не из Центр. офиса то выводить клиентов только своего РКО */
    if my_dep <> 1 and my_dep <> clnts_depart then do:
        delete clnts.
        next.
    end.
    
    /* контактное лицо */
    find first sub-cod where sub-cod.sub = 'cln'
                       and sub-cod.acc = cif.cif
                       and sub-cod.d-cod = 'clnbk'
                       and sub-cod.ccode = 'mainbk'
                       use-index dcod no-lock no-error.
    if avail sub-cod then
        clnts_contact = sub-cod.rcode.
end.

run start_html("Автоматизированный отчет по ю/л").
{&HTML} html_table(0,0,'0') crlf.
for each clnts break by clnts_d:
    if first-of(clnts_d) then do:
        i = 1.
        find first ppoint where ppoint.depart = clnts_depart no-lock no-error.
        if avail ppoint then
            deprt = ppoint.name.
        {&HTML} html_elbat() crlf
                "<p class=hh3>Департамент: <b>" deprt "</b></p>" crlf
                html_table(3, 1, "100%") crlf
                "<tr>" crlf
                "<td class=hdr>No</td>" crlf
                "<td class=hdr>Организация</td>" crlf
                "<td class=hdr>Виды банковских операций</td>" crlf
                "<td class=hdr>Контактное лицо</td>" crlf
                "<td class=hdr>Юридический адрес</td>" crlf
                "<td class=hdr>Руководитель</td>" crlf
                "<td class=hdr>Телефон1</td>" crlf
                "<td class=hdr>Телефон2</td>" crlf
                "</tr>" crlf.
    end.
    {&HTML} "<tr valign=top>" crlf
            "<td>" i "</td>" crlf
            "<td>" clnts_name "</td>" crlf
            "<td nowrap>".
    if clnts_iscred then 
        {&HTML} '-обслуживание кредитной линии;<br>'.
    if clnts_isaccnt then
        {&HTML} '-расчетный счет;<br>'.
    if clnts_isdep then
        {&HTML} '-депозит;<br>'.

    {&HTML} "<td>" clnts_contact "</td>" crlf
            "<td>" clnts_addr "</td>" crlf
            "<td>" clnts_head "</td>" crlf
            "<td>" clnts_phone1 "</td>" crlf
            "<td>" clnts_phone2 "</td>" crlf
            "</tr>" crlf.
    i = i + 1.
end.
{&HTML} html_elbat().
pause 0.
hide frame process_frame.
run finish_html.
