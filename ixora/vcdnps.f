/* vcdnps.f
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
*/

/* vcdnps.f Валютный контроль
   Форма паспорта сделки/доплиста

   18.10.2002 nadejda создан
   21.03.2008 galina изменен формат вывода номера паспорта сделки
   07.04.2008 galina - добавлено новое поле "ОСНОВ.ОФОРМ";
                       выбор значения поля "ОСНОВ.ОФОРМ" из справочника
   17.04.2008 galina - ввод значений поля "ОСНОВ.ОФОРМ" вручную через запятую;
                       проверка наличия значений поля "ОСНОВ.ОФОРМ" в справочнике;
                       добавлены поля СРОКИ, ВАЛЮТ.ОГОВОРКА, ФОРМЫ РАСЧЕТОВ, ВАЛЮТЫ ПЛАТЕЖА
   18.05.2009 galina - возмоность ввода пустой даты завершения контракта
   7/10/2010 aigul - полe "ОСОБЫЕ ОТМ" увеличение на 6 строк и каждую по 50 символов
   25/11/2010 galina - поправила редактирование поля "ОСОБЫЕ ОТМ"
   17.01.2011 aigul     - добавила вывод след данных в МТ111 (запись идет в поле vcps.info[3])
                        11 ОКПО банка
                        12 Наименование экспортера/импортера
                        13 Код ОКПО экспортера/импортера
                        14 Код РНН экспортера/импортера
                        15 ОПФ экспортера/импортера
                        16 Номер контракта
                        17 Дата контракта
                        18 Сумма контракта
                        19 Наименование нерезидента
                        20 страна нерезидента
                        21 Сроки репатриации
                        22 Особые отметки
                        23 Валюта контракта
                        24 Последняя дата
                        25 Валюта платежа
                        26 Код способа расчетов
                        27 Вал оговорка
                        28 Детали вал оговорки
    30.09.2011 damir    - добавил vcps.okpoprev во фрейм vcdnps.
    26.10.2011 aigul    - подправила удаление данных из vcps.info[3]
    29.06.2012 damir    - внедрено Т.З. № 1355, изменения в vcdnps.f.
    10.07.2012 damir    - перекомпиляция.


*/


def var v-dntypename    as char.
def var v-nbcrckod      as char.
def var v-sumdoccon     as decimal.
def var v-rslctype      as char format "x(4)".
def var v-rslcdate      as date format "99/99/99".
def var v-rslcnum       as char format "x(18)".
def buffer b-vcps       for vcps.
def buffer b2-vcps      for vcps.
def var msg-err         as char.
def var v-comcod        as char.
def var v-comsum        as deci.
def var v-comcrc        as char.
def var v-comdate       as date.
def var v-comjh         as char.
def var v-psreason      as char no-undo.
def var v-sel           as integer no-undo.


{vc-crosscurs.i}


/*Проверка правильности основ.оформ.доп.листа*/

function check-psreas returns char (p-psreas as char).
  def var i as integer.
  def var s as char.
  def var l as logical.
  def var v-psreason_int as char no-undo.

  if v-psreason_int = "" then do:
   for each codfr where codfr.codfr = 'vcpsreas' and codfr.code <> 'msc' no-lock:
     v-psreason_int = v-psreason_int + string(integer(codfr.code)).
   end.
 end.

  p-psreas = trim(p-psreas).
  if p-psreas = ""   then s = "*".
  else do:
    if substring(p-psreas, length(p-psreas), 1) = "," then
      p-psreas = substring(p-psreas, length(p-psreas) - 1).
    l = true.
    do i = 1 to num-entries(p-psreas) :
      s = entry(i, p-psreas).
      if s = "" or (index(v-psreason_int,s) = 0) then do:
        l = false.
        if s = "" then s = "*".
        leave.
      end.
    end.
    if l then s = "".
  end.
  return s.
end.

function chk-dndate returns logical (p-value as date).
    if p-value = ? then do:
    msg-err = "Введите дату документа!". return false. end.
    if p-value < vccontrs.ctdate then do:
    msg-err = "Дата документа не может быть меньше даты контракта!". return false. end.
    if vcps.dntype = "01" and p-value > vccontrs.lastdate and (vccontrs.cttype <> '1' or  vccontrs.lastdate <> ?) then do:
    msg-err = "Дата паспорта сделки не может быть больше последней даты контракта!". return false. end.
    if can-find(b-vcps where b-vcps.contract = s-contract and
    b-vcps.dntype = vcps.dntype and b-vcps.dnnum = vcps.dnnum and
    b-vcps.dndate = p-value and b-vcps.ps <> vcps.ps no-lock) then do:
    msg-err = "Уже есть документ с таким номером и датой по данному контракту!". return false. end.
    /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
    find ncrc where ncrc.crc = vcps.ncrc no-lock no-error.
    if avail ncrc then if ncrc.prefix <> "" and date(entry(2, ncrc.prefix)) <= p-value then do:
        msg-err = "Нельзя пользоваться валютой " + ncrc.code + " после " + entry(2, ncrc.prefix) +
        " - заменена " + entry(1, ncrc.prefix) + " !".
        return false.
    end.
    return true.
end.

function chk-dnnum returns logical (p-value as char).
    if p-value = "" then do:
    msg-err = "Введите номер документа!". return false. end.
    if can-find(b-vcps where b-vcps.contract = s-contract and
    b-vcps.dntype = vcps.dntype and b-vcps.dnnum = p-value and
    b-vcps.dndate = vcps.dndate and b-vcps.ps <> vcps.ps no-lock) then do:
    msg-err = "Уже есть документ с таким номером и датой по данному контракту!". return false. end.
    return true.
end.

function chk-crc returns logical (p-value as integer).
    def var v-curs as deci.

    find ncrc where ncrc.crc = p-value no-lock no-error.
    if not avail ncrc then do:
    msg-err = "Недопустимый код валюты!". return false. end.
    /*
    if p-value <> vccontrs.ncrc and lookup(ncrc.code, vccontrs.ctvalpl) = 0 then do:
    msg-err = "Выбранная валюта не является валютой контракта и не входит в список валют платежа!".
    return false.
    end.
    */
    /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
    find ncrc where ncrc.crc = p-value no-lock no-error.
    if avail ncrc then if ncrc.prefix <> "" and date(entry(2, ncrc.prefix)) <= vcps.dndate then do:
        msg-err = "Нельзя пользоваться валютой " + ncrc.code + " после " + entry(2, ncrc.prefix) +
        " - заменена " + entry(1, ncrc.prefix) + " !".
        return false.
    end.

    return true.
end.

function check-formrs returns char (p-formrs as char).
    def var i as integer.
    def var s as char.
    def var l as logical.
    p-formrs = trim(p-formrs).
    if p-formrs = "" then s = "".
    else do:
        if substring(p-formrs, length(p-formrs), 1) = "," then
        p-formrs = substring(p-formrs, length(p-formrs) - 1).
        l = true.
        do i = 1 to num-entries(p-formrs) :
            s = entry(i, p-formrs).
            if (s = "" or s = "msc" or
            not can-find(codfr where codfr.codfr = "vcfpay" and codfr.code = s no-lock)) then do:
            l = false. leave. end.
        end.
        if l then s = "".
    end.
    return s.
end.

function check-valpl returns char (p-valpl as char).
    def var i as integer.
    def var s as char.
    def var l as logical.
    p-valpl = trim(p-valpl).
    if p-valpl = "" then s = "".
    else do:
        if substring(p-valpl, length(p-valpl), 1) = "," then
        p-valpl = substring(p-valpl, length(p-valpl) - 1).
        l = true.
        do i = 1 to num-entries(p-valpl) :
            s = entry(i, p-valpl).
            if (s = "" or not (can-find(ncrc where ncrc.code = s no-lock))) then do:
            l = false. leave. end.
        end.
        if l then s = "".
    end.
    return s.
end.


form

    vcps.dntype colon 12 format "xx" validate(vcps.dntype <> "" and vcps.dntype <> "msc" and
    can-find(codfr where codfr.codfr = "vcdoc" and codfr.code = vcps.dntype and
    codfr.name[5] = "s" no-lock) and ((vcps.dntype <> "01") or
    not can-find(b-vcps where b-vcps.contract = s-contract and b-vcps.dntype = "01"
    and b-vcps.ps <> vcps.ps no-lock)),
    "Неверный тип документа или паспорт сделки уже введен!")
    v-dntypename format "x(15)" no-label
    vcps.rdt label "РЕГ." colon 39 vcps.rwho no-label colon 50 skip
    /*vcps.info[4] colon 12 label "ОСНОВ.ОФОРМ" format "x(5)" validate(check-psreas(vcps.info[4]) = "",
    " Введен неверное основ.оформления доп.листа или не заполнена измененная информация" + replace(check-psreas(vcps.info[4]),'*','') + " !")
    help " Код основ.оформления доп.листа по классификатору (F2 - помощь)"*/
    vcps.cdt label "АКЦ." colon 39 vcps.cwho no-label colon 50 skip
    v-dnnum colon 12 format "x(50)" label "НОМЕР"/* validate(chk-dnnum(vcps.dnnum), msg-err)*/ skip
    vcps.dndate colon 12 validate(chk-dndate(vcps.dndate), msg-err)
    vcps.lastdate colon 39 validate(vcps.lastdate = ? or vcps.lastdate >= vcps.dndate,
    "Последняя дата не может быть меньше даты документа!") skip
    vcps.ncrc colon 12 format ">>9" label "ВАЛЮТА" validate(chk-crc(vcps.ncrc), msg-err)
    v-nbcrckod format "xxx" no-label
    vcps.sum colon 39 validate(vcps.sum >= 0, "Сумма не может быть отрицательной!") skip
    vcps.ctvalpl label "ВАЛ.ПЛ." colon 12 format "x(20)" validate(check-valpl(vcps.ctvalpl) = "",
    " Введен неверный код валюты " + check-valpl(vcps.ctvalpl) + " !") skip
    /*vcps.ctvalogr label "ВАЛЮТ.ОГОВ" colon 12 format "x(50)" skip*/
    vcps.cursdoc-con label "К ВАЛ.КОН." colon 12 format ">>>>>>>>>9.9999<<"
    validate(vcps.cursdoc-con > 0, "Курс не может быть нулевым!")
    v-sumdoccon format ">>>,>>>,>>>,>>>,>>9.99" label "В ВАЛ.КОН" colon 39 skip
    vcps.ctterm colon 12 format "999.99"
    /*vcps.ctformrs colon 39 format "x(24)" validate(check-formrs(vcps.ctformrs) = "",
    " Введен неверный код формы расчетов " + check-formrs(vcps.ctformrs) + " !") skip*/
    /*vcps.rslc colon 12 label "РЕГ.СВ/ЛИЦ"*/
    /*vcps.okpoprev colon 12 label "ОКПО пред." format "x(12)"*/  /*ОКПО предыдущего банка*/
    v-rslctype no-label colon 25
    v-rslcdate no-label colon 30 v-rslcnum no-label colon 39
    vcps.dnnote[1] colon 12 format "x(20)" label  "ОТ БАНКА"
    vcps.dnnote[2] colon 42 format "x(20)" label "КЛИЕНТА" skip
    /*vcps.dnnote[3] colon 12 format "x(50)" label "ОТ ТАМОЖНИ" skip*/
    /*vcps.dnnote[4] colon 12 format "x(50)" label "ВАЛЮТ.ОГОВ" skip*/
    /*vcps.dnnote[5]*/ v-note colon 12 format "x(50)" label "ОСОБЫЕ ОТМ" skip
    v-note1 colon 12 format "x(50)" label "" skip
    v-note2 colon 12 format "x(50)" label "" skip
    v-note3 colon 12 format "x(50)" label "" skip
    v-note4 colon 12 format "x(50)" label "" skip
    v-note5 colon 12 format "x(50)" label "" skip


    v-comcod colon 12 format "x(4)" label "КОМИССИЯ"
    v-comjh colon 23 format "x(8)" label "TRX"
    v-comdate colon 31 format "99/99/99" no-label
    v-comsum colon 49 format "zzz,zz9.99" label "СУММА"
    v-comcrc format "x(3)" no-label skip

  with row 4 width 66 overlay side-label title "КОНТРАКТ : " + v-contrnum frame vcdnps.

{vc-summf.i}

def var v-sel1      as char.
def var v-del       as char.
def var spn         as char.
def var j           as inte.
def var v-cont      as inte.
def var v-psnum1    as char.
def var v-psreason1 as char.
def var i           as inte.

def temp-table wrk-mt
    field code as int format "99"
    field name as char format "x(33)"
    field choice as char format "x(2)".

do i = 1 to 18:
    create wrk-mt.
    assign wrk-mt.code = i.
    if i = 1  then wrk-mt.name = "ОКПО банка".
    if i = 2  then wrk-mt.name = "Наименование экспортера/импортера".
    if i = 3  then wrk-mt.name = "Код ОКПО экспортера/импортера".
    if i = 4  then wrk-mt.name = "Код РНН экспортера/импортера".
    if i = 5  then wrk-mt.name = "ОПФ экспортера/импортера".
    if i = 6  then wrk-mt.name = "Номер контракта".
    if i = 7  then wrk-mt.name = "Дата контракта".
    if i = 8  then wrk-mt.name = "Сумма контракта".
    if i = 9  then wrk-mt.name = "Наименование нерезидента".
    if i = 10 then wrk-mt.name = "Страна нерезидента".
    if i = 11 then wrk-mt.name = "Сроки репатриации".
    if i = 12 then wrk-mt.name = "Особые отметки".
    if i = 13 then wrk-mt.name = "Валюта контракта".

    find vcps where vcps.ps = s-ps no-lock no-error.
    if avail vcps then do:
        if vcps.dntype = "19" then do:
            if i = 14 then wrk-mt.name = "Последняя дата".
            if i = 15 then wrk-mt.name = "Валюта платежа".
            if i = 16 then wrk-mt.name = "Код способа расчетов".
            if i = 17 then wrk-mt.name = "Валютная оговорка".
            if i = 18 then wrk-mt.name = "Детали валютной оговорки".
        end.
    end.
    wrk-mt.choice = "".
end.

on help of vcps.ncrc,vcps.sum,vcps.ctterm in frame vcdnps do:
    /*if s-check = "reason" then do:
        if v-psreason = "" then do:
            for each codfr where codfr.codfr = 'vcpsreas' and codfr.code <> 'msc' no-lock:
                if v-psreason <> "" then v-psreason = v-psreason + " |".
                v-psreason = v-psreason + string(codfr.code) + " " + codfr.name[1].
            end.
        end.
        v-sel = 0.
        run sel2 ("ВЫБЕРИТЕ ОСНОВАНИЕ ОФОРМЛЕНИЯ ДОП.ЛИСТА", v-psreason, output v-sel).
        if v-sel <> 0 then do:
            update vcps.info[4] = string(v-sel) with frame vcdnps.
            displ vcps.info[4] with frame vcdnps.
        end.
    end.*/

    if s-check = "changeF2" then do:
        for each wrk-mt where wrk-mt.name <> "" no-lock break by wrk-mt.code:
            if v-psreason1 <> "" then v-psreason1 = v-psreason1 + " |".
            v-psreason1 = v-psreason1 + wrk-mt.name.
        end.
        v-sel1 = "".
        v-cont = vccontrs.contract.
        v-psnum1 = vcps.dnnum.
        run sel_mt ("insert - выбор изменненной графы, delete - отменить выбор", v-psreason1, v-cont, v-psnum1, output v-sel1, output v-del).
        if v-sel1 <> ""  then do:
            if lookup('1',v-sel1) > 0  then do:
                if not lookup('11',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '11'.
                    else vcps.info[3] = '11'.
                end.
            end.
            if lookup('2',v-sel1) > 0  then do:
                if not lookup('12',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '12'.
                    else vcps.info[3] = '12'.
                end.
            end.
            if lookup('3',v-sel1) > 0  then do:
                if not lookup('13',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '13'.
                    else vcps.info[3] = '13'.
                end.
            end.
            if lookup('4',v-sel1) > 0  then do:
                if not lookup('14',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '14'.
                    else vcps.info[3] = '14'.
                end.
            end.
            if lookup('5',v-sel1) > 0  then do:
                if not lookup('15',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '15'.
                    else vcps.info[3] = '15'.
                end.
            end.
            if lookup('6',v-sel1) > 0  then do:
                if not lookup('16',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '16'.
                    else vcps.info[3] = '16'.
                end.
            end.
            if lookup('7',v-sel1) > 0  then do:
                if not lookup('17',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '17'.
                    else vcps.info[3] = '17'.
                end.
            end.
            if lookup('8',v-sel1) > 0  then do:
                if not lookup('18',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '18'.
                    else vcps.info[3] = '18'.
                end.
            end.
            if lookup('9',v-sel1) > 0  then do:
                if not lookup('19',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '19'.
                    else vcps.info[3] = '19'.
                end.
            end.
            if lookup('10',v-sel1) > 0  then do:
                if not lookup('20',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '20'.
                    else vcps.info[3] = '20'.
                end.
            end.
            if lookup('11',v-sel1) > 0  then do:
                if not lookup('21',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '21'.
                    else vcps.info[3] = '21'.
                end.
            end.
            if lookup('12',v-sel1) > 0  then do:
                if not lookup('22',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '22'.
                    else vcps.info[3] = '22'.
                end.
            end.
            if lookup('13',v-sel1) > 0  then do:
                if not lookup('23',vcps.info[3]) > 0  then do:
                    if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '23'.
                    else vcps.info[3] = '23'.
                end.
            end.
            find vcps where vcps.ps = s-ps exclusive-lock no-error.
            if avail vcps then do:
                if vcps.dntype = "19" then do:
                    if lookup('14',v-sel1) > 0  then do:
                        if not lookup('24',vcps.info[3]) > 0  then do:
                            if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '24'.
                            else vcps.info[3] = '24'.
                        end.
                    end.
                    if lookup('15',v-sel1) > 0  then do:
                        if not lookup('25',vcps.info[3]) > 0  then do:
                            if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '25'.
                            else vcps.info[3] = '25'.
                        end.
                    end.
                    if lookup('16',v-sel1) > 0  then do:
                        if not lookup('26',vcps.info[3]) > 0  then do:
                            if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '26'.
                            else vcps.info[3] = '26'.
                        end.
                    end.
                    if lookup('17',v-sel1) > 0  then do:
                        if not lookup('27',vcps.info[3]) > 0  then do:
                            if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '27'.
                            else vcps.info[3] = '27'.
                        end.
                    end.
                    if lookup('18',v-sel1) > 0  then do:
                        if not lookup('28',vcps.info[3]) > 0  then do:
                            if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '28'.
                            else vcps.info[3] = '28'.
                        end.
                    end.
                end.
                else if vcps.dntype = "04" then do:
                    if lookup('14',v-sel1) > 0  then do:
                        if not lookup('28',vcps.info[3]) > 0  then do:
                            if vcps.info[3] <> "" then vcps.info[3] = vcps.info[3] + ',' + '28'.
                            else vcps.info[3] = '28'.
                        end.
                    end.
                end.
            end.
        end.
        if v-del <> "" then do:
            find vcps where vcps.ps = s-ps exclusive-lock no-error.
            if avail vcps then do:
                if vcps.dntype = "19" then do:
                    if lookup('18',v-del) > 0  then do:
                        if lookup('28',vcps.info[3]) > 0  then do:
                            vcps.info[3] = replace(vcps.info[3],",28,",",").
                            vcps.info[3] = replace(vcps.info[3],"28,","").
                            vcps.info[3] = replace(vcps.info[3],"28","").
                        end.
                    end.
                    if lookup('17',v-del) > 0  then do:
                        if lookup('27',vcps.info[3]) > 0  then do:
                            vcps.info[3] = replace(vcps.info[3],",27,",",").
                            vcps.info[3] = replace(vcps.info[3],"27,","").
                            vcps.info[3] = replace(vcps.info[3],"27","").
                        end.
                    end.
                    if lookup('16',v-del) > 0  then do:
                        if lookup('26',vcps.info[3]) > 0  then do:
                            vcps.info[3] = replace(vcps.info[3],",26,",",").
                            vcps.info[3] = replace(vcps.info[3],"26,","").
                            vcps.info[3] = replace(vcps.info[3],"26","").
                        end.
                    end.
                    if lookup('15',v-del) > 0  then do:
                        if lookup('25',vcps.info[3]) > 0  then do:
                            vcps.info[3] = replace(vcps.info[3],",25,",",").
                            vcps.info[3] = replace(vcps.info[3],"25,","").
                            vcps.info[3] = replace(vcps.info[3],"25","").
                        end.
                    end.
                    if lookup('14',v-del) > 0  then do:
                        if lookup('24',vcps.info[3]) > 0  then do:
                            vcps.info[3] = replace(vcps.info[3],",24,",",").
                            vcps.info[3] = replace(vcps.info[3],"24,","").
                            vcps.info[3] = replace(vcps.info[3],"24","").
                        end.
                    end.
                end.
                else if vcps.dntype = "04" then do:
                    if lookup('14',v-del) > 0  then do:
                        if lookup('28',vcps.info[3]) > 0  then do:
                            vcps.info[3] = replace(vcps.info[3],",28,",",").
                            vcps.info[3] = replace(vcps.info[3],"28,","").
                            vcps.info[3] = replace(vcps.info[3],"28","").
                        end.
                    end.
                end.
            end.
            if lookup('13',v-del) > 0  then do:
                if lookup('23',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",23,",",").
                    vcps.info[3] = replace(vcps.info[3],"23,","").
                    vcps.info[3] = replace(vcps.info[3],"23","").
                end.
            end.
            if lookup('12',v-del) > 0  then do:
                if lookup('22',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",22,",",").
                    vcps.info[3] = replace(vcps.info[3],"22,","").
                    vcps.info[3] = replace(vcps.info[3],"22","").
                end.
            end.
            if lookup('11',v-del) > 0  then do:
                if lookup('21',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",21,",",").
                    vcps.info[3] = replace(vcps.info[3],"21,","").
                    vcps.info[3] = replace(vcps.info[3],"21","").
                end.
            end.
            if lookup('10',v-del) > 0  then do:
                if lookup('20',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",20,",",").
                    vcps.info[3] = replace(vcps.info[3],"20,","").
                    vcps.info[3] = replace(vcps.info[3],"20","").
                end.
            end.
            if lookup('9',v-del) > 0  then do:
                if lookup('19',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",19,",",").
                    vcps.info[3] = replace(vcps.info[3],"19,","").
                    vcps.info[3] = replace(vcps.info[3],"19","").
                end.
            end.
            if lookup('8',v-del) > 0  then do:
                if lookup('18',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",18,",",").
                    vcps.info[3] = replace(vcps.info[3],"18,","").
                    vcps.info[3] = replace(vcps.info[3],"18","").
                end.
            end.
            if lookup('7',v-del) > 0  then do:
                if lookup('17',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",17,",",").
                    vcps.info[3] = replace(vcps.info[3],"17,","").
                    vcps.info[3] = replace(vcps.info[3],"17","").
                end.
            end.
            if lookup('6',v-del) > 0  then do:
                if lookup('16',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",16,",",").
                    vcps.info[3] = replace(vcps.info[3],"16,","").
                    vcps.info[3] = replace(vcps.info[3],"16","").
                end.
            end.
            if lookup('5',v-del) > 0  then do:
                if lookup('15',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",15,",",").
                    vcps.info[3] = replace(vcps.info[3],"15,","").
                    vcps.info[3] = replace(vcps.info[3],"15","").
                end.
            end.
            if lookup('4',v-del) > 0  then do:
                if lookup('14',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",14,",",").
                    vcps.info[3] = replace(vcps.info[3],"14,","").
                    vcps.info[3] = replace(vcps.info[3],"14","").
                end.
            end.
            if lookup('3',v-del) > 0  then do:
                if lookup('13',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",13,",",").
                    vcps.info[3] = replace(vcps.info[3],"13,","").
                    vcps.info[3] = replace(vcps.info[3],"13","").
                end.
            end.
            if lookup('2',v-del) > 0  then do:
                if lookup('12',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",12,",",").
                    vcps.info[3] = replace(vcps.info[3],"12,","").
                    vcps.info[3] = replace(vcps.info[3],"12","").
                end.
            end.
            if lookup('1',v-del) > 0  then do:
                if lookup('11',vcps.info[3]) > 0  then do:
                    vcps.info[3] = replace(vcps.info[3],",11,",",").
                    vcps.info[3] = replace(vcps.info[3],"11,","").
                    vcps.info[3] = replace(vcps.info[3],"11","").
                end.
            end.
        end.
    end.
end.

