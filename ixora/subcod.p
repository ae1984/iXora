 /* subcod.p
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
        22.02.05 saltanat - При работе со справочником "scann" для клиентов сделала занесение даты в rcode при проставлении признака Сканирования.
        04.06.05 tsoy - По умолчанию платеж обычный
	    19.09.05 u00121 - добавлена возможность формирования базы отпечатков пальцев и сканирование отпечатков для сравнения для Директора и Гл.бухгалтера из справочников
        13/08/2010 aigul - Добавила alert message для обязательного заполнения ФИО ИП
        18/11/2010 madiyar - обязательное заполнение признака сегментации клиента
        24.11.2010 aigul - Добавила alert message для объязательного заполнения zdcavail and zsgavail
        1/12/2010 aigul - сделала проверку на сектор экономики 9 при заполнении полей zdcavail and zsgavail:
                            1 Проверяет клиента, выбирает только ФЛ или ИП
                            2 для входящих платежей она проверяет КБе  должно быть19 или 29 (а КБЕ игнорирует)
                            3 для исходящих КОд должно быть 19 или 29 (игнорирует КОд)
                            4 проверка что они оба (отправитель и получатель) не являются резидентами (то есть один из них должен быть нерезидентом)
        15.12.2010 evseev - создание фрейма для ввода документ, номер документа и дата документа. Запись этих полей в rcode в признаке clnuoo.
        10.06.2011 aigul - ввод данных УЛ
        28.03.2012 Lyubov - добавила новый справочник ecdivisg, который ориентируется на значение справочника ecdivis
        29.03.2012 Lyubov - подправила алгоритмы определения справочников ecdivis и ecdivisg, добавила мессаджи
        31.05.2012 dmitriy - если гл.бух "не предусмотрен", то поля с информацией о гл.бухе не активны для редактирования
        20.05.2013 damir - Внедрено Т.З. № 1803.
        30.10.2013 evseev tz 1890
*/

/* h-quetyp.p */
{global.i}
{codcondit.i} /* функция проверки введенного значения для отсечения части кодов справочника */


run savelog('subcod', '************ ' + g-cif).
run savelog('subcod', THIS-PROCEDURE:FILE-NAME                                                                   ).
run savelog('subcod', THIS-PROCEDURE:INSTANTIATING-PROCEDURE:NAME                                                ).
run savelog('subcod', THIS-PROCEDURE:INSTANTIATING-PROCEDURE:INSTANTIATING-PROCEDURE:NAME                        ).
run savelog('subcod', THIS-PROCEDURE:INSTANTIATING-PROCEDURE:INSTANTIATING-PROCEDURE:INSTANTIATING-PROCEDURE:NAME).
run savelog('subcod', THIS-PROCEDURE:INSTANTIATING-PROCEDURE:INSTANTIATING-PROCEDURE:INSTANTIATING-PROCEDURE:INSTANTIATING-PROCEDURE:NAME).



def var v-subcodedt as logical.
v-subcodedt = yes.
if THIS-PROCEDURE:INSTANTIATING-PROCEDURE:INSTANTIATING-PROCEDURE:NAME = "s-cifot" then v-subcodedt = no.
if THIS-PROCEDURE:INSTANTIATING-PROCEDURE:INSTANTIATING-PROCEDURE:NAME = "s-cif" then do:
   find first cif where cif.cif = g-cif no-lock no-error.
   if avail cif then do:
      find last crg where crg.crg = cif.crg and crg.stn = 1 use-index crg no-lock no-error.
      if avail crg then do: message 'Для редактирования необходимо снять акцепт карточки клиента в п.м. 1.1.4 «Контроль признаков клиента»' view-as alert-box. return. end.
   end.
end.

/*
{ps-prmt.i}
*/
def var h as int .
def var i as int .
def var d as int .
def var v-codname like sub-cod.rcode  format 'x(45)'.
def input parameter v-acc like aaa.aaa .
def input parameter v-sub like gl.sub .
def var v-rez like sub-cod.rcode .
def var yn as log init false .
/*
def var v-acc like aaa.aaa init "RMZ622981A" .
def var v-sub like gl.sub  init "rmz" .
*/
def var v-from as cha format "x(1)" .
def buffer b-sub for sub-cod .
def var dicname as cha .
def var codname as cha .
def new shared var v-code like codfr.code .
def new shared var v-d-cod like codfr.codfr .
def var v-old as int init 0 .
def var errormess as char.
def var bilance   as decimal format '->,>>>,>>>,>>9.99'.
def var v-rez1 as char.
def var v-rez2 as char.
def var v-status as logical initial yes.
def var v-zsg as char.
def var v-zdc as char.
def var v-eknp1 as char.
def var v-eknp2 as char.
def var ecdivcls as char.
def var ecdivdes as char.
def var codcod as char.
def var codcod1 as char.
def var a as char init "ecdivis".

def var v-docname as char format "x(40)".
def var v-docnum as char format "x(20)".
def var v-docdate as date format '99/99/9999'.
def var v-class as char format "x(5)".
def var v-day as int.
def var v-month as int.
def var v-year as int.
def var v-date as char.
def var v-days as int.
def var v-dir as char.
def var v-buh as char.
def var v-clnbk as logi init true.
def var v-oldcode as char.
h = 13 .
d = 60.
def buffer b-sub-cod for sub-cod.
find first sub-cod where sub-cod.acc = v-acc and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnbk'
                    and sub-cod.ccod = 'mainbk' no-lock no-error.
                    if avail sub-cod then v-buh = sub-cod.rcode.
find first sub-cod where sub-cod.acc = v-acc and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnchf' and sub-cod.ccod = 'chief' no-lock no-error.
                    if avail sub-cod then v-dir = sub-cod.rcode.
do:
    {browpnpj.i &h = "h"
    &form = "browform.i"
    &first = "do transact:
                    run fnew.
                    form  v-codname label 'Значение' with side-label overlay centered row 10 frame vvv.
                    form  dicname format 'x(50)' with no-label centered row 18 frame dop.
                    form  ' < Пробел > - изменить F10 - удалить < Enter > - ручной ввод ' with no-label centered row 21 no-box frame ddd .
                    form  v-docname label 'Документ' skip v-docnum label 'Номер документа' skip v-docdate label 'Дата документа' with side-label overlay centered row 15 frame nnd.
              end."
    &where = "sub-cod.acc = v-acc and sub-cod.sub = v-sub use-index dcod "
    &frame-phrase = "row 1 centered scroll 1 h down overlay title v-acc + ' ' + v-sub "
    &predisp = "view frame ddd. dicname = ''. codname = ''.
                find first codific where codific.codfr = sub-cod.d-cod no-lock   no-error.
                if avail codific then dicname = codific.name .
                find first codfr where codfr.codfr = codific.codfr and codfr.code = sub-cod.ccode  no-lock no-error.
                if (sub-cod.rcode ne '' and sub-cod.d-cod <> 'clnuoo') or (substr(codfr.name[1],1,3) eq '#$%' and sub-cod.d-cod <> 'clnuoo')then codname = sub-cod.rcode .
                else do:
                    if codfr.codfr = a then codcod = codfr.code.
                    if (num-entries (sub-cod.rcode,'^') = 3 and sub-cod.d-cod = 'clnuoo') then do:
                       codname = codfr.name[1] + ',' + entry(1, sub-cod.rcode ,'^') + '' + entry(2, sub-cod.rcode ,'^') + ',' + entry(3, sub-cod.rcode ,'^').
                    end.
                    else codname = codfr.name[1].
                end.
                if substr(codfr.name[1],1,3) = '#$%' then v-from = 'P'.
                else if sub-cod.rcode = '' or sub-cod.d-cod = 'clnuoo' then v-from = 'S'. else  v-from = 'R' .
                display dicname with frame dop  . v-old = cur .

                v-clnbk = true.
                if (sub-cod.d-cod = 'clnbkdt' or sub-cod.d-cod = 'clnbkdtex' or sub-cod.d-cod = 'clnbknum' or sub-cod.d-cod = 'clnbkpl') then do:
                    find first b-sub-cod where b-sub-cod.acc = v-acc and b-sub-cod.sub = 'cln' and b-sub-cod.d-cod = 'clnbk' and b-sub-cod.ccod = 'mainbk' no-lock no-error.
                    if avail b-sub-cod and b-sub-cod.rcode = 'не предусмотрен' then v-clnbk = false.
                    else v-clnbk = true.
                end.
                "
    &seldisp = "sub-cod.ccode"
    &file = "sub-cod"
    &disp = "sub-cod.d-cod sub-cod.ccode codname sub-cod.rdt v-from "
    &preupd = "if v-subcodedt = no then do: message 'Редактирование запрещено!' view-as alert-box. leave. end. if v-clnbk = false then leave. "
    &postupd = "if v-subcodedt = no then do: message 'Редактирование запрещено!' view-as alert-box. leave. end.
                if (sub-cod.rcode ne '' and codfr.name[1] = '' and sub-cod.d-cod <> 'clnuoo')
                or (sub-cod.rcode = '' and codfr.name[1] = '' and sub-cod.d-cod <> 'clnuoo') then do:
                    if sub-cod.d-cod = 'clnbkdt' then do:
                        run fill_dt(output v-date).
                        sub-cod.rcode = v-date.
                    end.
                    else if sub-cod.d-cod = 'clnchfddt' then do:
                        run fill_dt(output v-date).
                        sub-cod.rcode = v-date.
                    end.
                    else if sub-cod.d-cod = 'clnbkdtex' then do:
                        run fill_dt(output v-date).
                        sub-cod.rcode = v-date.
                        v-days = date(v-date) - today.
                        if v-days <= 30 then
                        message 'Срок действия УЛ ' v-buh ' истекает через ' v-days ' дней!' view-as alert-box.
                    end.
                    else if sub-cod.d-cod = 'clnchfddtex' then do:
                        run fill_dt(output v-date).
                        sub-cod.rcode = v-date.
                        v-days = date(v-date) - today.
                        if v-days <= 30 then
                        message 'Срок действия УЛ ' v-dir ' истекает через ' v-days ' дней!' view-as alert-box.
                    end.
                    else do:
                        v-codname = sub-cod.rcode.
                        update v-codname with frame vvv.
                        sub-cod.rcode = v-codname.
                        for each loncon where loncon.cif = v-acc.
                            run atl-dat (loncon.lon,g-today,output bilance). /* остаток  ОД*/
                            if bilance > 0 then do:
                                if sub-cod.d-cod = 'clnbk' then loncon.galv-gram = v-codname.
                                if sub-cod.d-cod = 'clnchf' then loncon.vad-vards = v-codname.
                            end.
                        end.
                        hide frame vvv.
                        if sub-cod.d-cod = 'clnchf' or sub-cod.d-cod = 'clnbk' then
                        run fngrchief(input sub-cod.acc, input sub-cod.d-cod).
                    end.
                end.
	            else if (sub-cod.rcode ne '' and substr(codfr.name[1],1,3) = '#$%' and sub-cod.d-cod <> 'clnuoo') or (sub-cod.rcode = '' and substr(codfr.name[1],1,3) = '#$%' and sub-cod.d-cod <> 'clnuoo') then do :
                    v-rez = sub-cod.rcod .
                    run value(substr(codfr.name[1],4))(input-output v-rez).
	                if v-rez ne '' then do :
                        sub-cod.rcode = v-rez.
                        sub-cod.rdt = g-today .
                        find first codfr where codfr.codfr = codific.codfr and codfr.code = sub-cod.ccode  exclusive-lock no-error.
                        codfr.code = codfr.codfr.
                        release codfr.
                    end.
                end.
                else run addpro .
                if avail sub-cod and sub-cod.sub = 'cln' and sub-cod.d-cod = 'scann' then do:
                    if sub-cod.ccode = 't' and sub-cod.rcode = '' then sub-cod.rcode = 'Сканирование,' + string(g-today ).
                    else if sub-cod.ccode <> 't' then sub-cod.rcode = ''.
                end. "
    &poscreat = "sub-cod.sub = v-sub.
                 sub-cod.acc = v-acc.
                 run addcod.
                 if not keyfunction(lastkey) = 'end-error'  then do:
                    find current sub-cod exclusive-lock no-error.
                    if avail sub-cod and sub-cod.d-cod = '' then do:
                        delete sub-cod.
                        cur = v-old.
                    end.
                    else cur = recid(sub-cod).
                 end. "
    &addupd = " "
    &postadd = " leave. "
    &enderr = " curold = cur .
                /*aigul*/
                if v-sub = 'cln' then do:
                    find first cif where cif.type = 'b' and cif.cif = v-acc no-lock no-error.
                    if avail cif then do:
                        find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-acc and sub-cod.d-cod = 'clnchf' and sub-cod.rcod = '' /*and sub-cod.ccod = 'msc'*/ no-lock no-error.
                        if avail sub-cod then do:
                             message 'Заполните поле clnchf!' view-as alert-box.
                             leave.
                        end.
                        find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-acc and sub-cod.d-cod = 'clnsegm' and sub-cod.ccode = 'msc' no-lock no-error.
                        if avail sub-cod then do:
                             message 'Заполните признак сегментации!' view-as alert-box.
                             leave.
                        end.
                        find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-acc and sub-cod.d-cod = a no-lock no-error.
                        if not avail sub-cod or sub-cod.ccode = 'msc' then do:
                            message 'Заполните раздел шифров отраслей экономики' view-as alert-box.
                            leave.
                        end.
                    end.
                    find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-acc and sub-cod.d-cod = 'bnkrel' and sub-cod.ccode = '01'  no-lock no-error.
                    if avail sub-cod then do:
                       find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-acc and sub-cod.d-cod = 'clnuoo'
                                                and sub-cod.ccode = 'msc'  no-lock no-error.
                       if avail sub-cod then do:
                             message 'Заполните условия обслуживания и основание!' view-as alert-box.
                             leave.
                       end.

                    end.
                 end.
                /*Вал Кон*/
                v-status = yes.
                find first remtrz where remtrz.remtrz = v-acc no-lock no-error.
                if avail remtrz then do:
                    find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = v-acc
                    and sub-cod.d-cod = 'eknp' no-lock no-error.
                    if avail sub-cod then do:
                        v-rez1 = substr(sub-cod.rcode,1,1).
                        v-rez2 = substr(sub-cod.rcode,4,1).
                        v-eknp1 = substr(sub-cod.rcode,1,2). /*КОД*/
                        v-eknp2 = substr(sub-cod.rcode,4,2). /*КБЕ*/
                    end.
                    if v-rez1 = '2' or v-rez2 = '2' then v-status = no.

                    /*Исх-й 6,2,4, вх-й 7,3*/
                    if (remtrz.ptype = '6' or remtrz.ptype = '2' or remtrz.ptype = '4' or remtrz.ptype = '7' or remtrz.ptype = '3') then do:
                        if (v-eknp1 = '29' or v-eknp1 = '19') or (v-eknp2 = '29' or v-eknp2 = '19') then do:
                            find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = v-acc
                            and lookup(sub-cod.d-cod,'zdcavail,zsgavail') > 0 and sub-cod.ccod = 'msc' no-lock  no-error.
                            if avail sub-cod and v-status = no then do:
                                message 'Заполните поле ' sub-cod.d-cod ' !' view-as alert-box.
                                leave.
                            end.
                        end.
                    end.
                end.

                find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = v-acc
                and sub-cod.d-cod = 'zdcavail' no-lock no-error.
                if avail sub-cod then v-zdc = sub-cod.ccod.
                find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = v-acc
                and sub-cod.d-cod = 'zsgavail' no-lock no-error.
                if avail sub-cod then v-zsg = sub-cod.ccod.
                if (v-zdc = '1' and v-zsg = '1') or (v-zdc = '2' and v-zsg = '2') then do:
                    message 'Необходимо корректное заполнение полей zdcavail и zsgavail!' view-as alert-box.
                    leave.
                end.
                /**/
                find first sub-cod where sub-cod.acc = v-acc and
                sub-cod.sub = v-sub and  sub-cod.ccode eq '' use-index dcod no-lock no-error.
                if avail sub-cod then do:
                    yn = false .
                    Message 'Не все коды введены ! Выход ?' update yn .
                    if yn then do:
                        for each sub-cod where sub-cod.acc = v-acc and sub-cod.sub = v-sub
                        and sub-cod.ccode eq '' use-index dcod.
                            delete sub-cod.
                        end.
                    end.
                    else do:
                        cur = curold .
                        leave .
                    end.
                end.
                /*find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-acc
                and sub-cod.d-cod = 'uldtbuh' no-lock no-error.
                if avail sub-cod then do:
                    if sub-cod.rcod <> "" then
                    message sub-cod.rcod view-as alert-box.
                end.*/
                hide frame vvv.
                hide frame frm .
                hide frame dop.
                hide frame ddd."
    &addcon = "false"
    &preupdcondition = "preupdcondition.i"
    &updcon = "true"
    &delcon = "true"
    &retcon = "false"
    &befret = " "
    &action = " if keylabel(lastkey) = ' ' then
                    if v-from = 'S' then do:
                        if v-subcodedt = no then do: message 'Редактирование запрещено!' view-as alert-box. leave. end.
                        v-d-cod = sub-cod.d-cod.
                        v-oldcode = sub-cod.ccode.
                        if codfr.codfr = a + 'g' and codcod <> 'msc' then do:
                            run p-codific(codific.codfr,codcod,output v-code).
                            run p-codific1(codific.codfr,v-code,output v-code).
                        end.
                        else if codfr.codfr = a + 'g' and codcod = 'msc' then message 'Сначала заполните раздел шифров отраслей экономики' view-as alert-box.
                        else run p-codific(codific.codfr,'*',output v-code).
                        view frame frm.
                        pause 0.
                        if codific.codfr = 'clnuoo' and v-code <> 'msc' then do:
                           if num-entries (sub-cod.rcode,'^') = 3 then do:
                             v-docname = entry(1, sub-cod.rcode ,'^').
                             v-docnum = entry(2, sub-cod.rcode ,'^').
                             v-docdate = date(entry(3, sub-cod.rcode ,'^')).
                           end.
                           update v-docname validate (v-docname <> '' , 'Укажите документ!')
                                  v-docnum  validate (v-docnum <> '' , 'Укажите номер документа!')
                                  v-docdate format '99/99/9999'
                                     with frame nnd.
                           hide frame nnd .
                        end.
                        else do:
                          v-docname = ''.
                          v-docnum = ''.
                          /*v-docdate = .*/
                        end.
                        if v-code ne '' and v-code ne sub-cod.ccode then do :
                            run subfor.
                            find current sub-cod no-lock.
                        end.
                    end."

    }

end.

/*PROCEDURE SUBFOR*/
procedure subfor.
    def var emess as char.
    def var v-bool as logi.
    if not isvalidcod(v-code, output emess) then do:
        message emess.
        pause.
        leave.
    end.
    find current sub-cod exclusive-lock.
    sub-cod.ccode = v-code.
    sub-cod.rdt = g-today .

    if sub-cod.d-cod = "arptype" and v-oldcode <> v-code then run addrec.

    find first codfr where codfr.codfr = sub-cod.d-cod and
    codfr.code = v-code  no-lock no-error.
    if substr(codfr.name[1],1,3) = '#$%' then do:
        v-rez = ' , ,'.
        run value(substr(codfr.name[1],4))(input-output v-rez).
        if v-rez ne ''  then do:
            sub-cod.rcode = v-rez.
            sub-cod.rdt = g-today .
            end.
        else
            if sub-cod.d-cod = 'clnuoo' and v-code <> 'msc' then do:
               sub-cod.rcode = v-docname + '^' + v-docnum + '^' + string(v-docdate, '99/99/9999').
            end.
            else do: sub-cod.rcode = ''.  end.
    end.
    else
        if sub-cod.d-cod = 'clnuoo' and v-code <> 'msc' then do:
          sub-cod.rcode = v-docname + '^' + v-docnum + '^' + string(v-docdate, '99/99/9999').
        end.
          else do: sub-cod.rcode = ''.  end. /* sub-cod.rwho = g-ofc. */
    if avail sub-cod and sub-cod.sub = 'cln' and sub-cod.d-cod = 'scann' then do:
        if v-code = 't' and sub-cod.rcode = '' then sub-cod.rcode = 'Сканирование,' + string(g-today ).
        else if v-code <> 't' then sub-cod.rcode = ''.
    end.
end procedure.
/*   PROCEDURE ADDCOD  */
procedure addcod .
    v-code = '' . v-d-cod = sub-cod.d-cod  .
    run h-ccode.
    if v-code ne '' and v-d-cod ne '' then do:
        find first b-sub where b-sub.acc = v-acc and b-sub.sub = v-sub and b-sub.d-cod = v-d-cod use-index dcod no-lock no-error .
        if avail b-sub and recid(b-sub) ne recid(sub-cod) then do :
            repeat :
                Message " Справочник уже используется ".
                pause .
                leave .
            end.
        end.
        else do:
            find current sub-cod exclusive-lock .
            sub-cod.ccode = v-code .
            sub-cod.d-cod = v-d-cod .
            sub-cod.rdt = g-today .
            find current sub-cod no-lock .

            if sub-cod.d-cod = "arptype" then run addrec.
        end.
    end.
    return .
end procedure .

/*   PROCEDURE ADDPRO  */
procedure addpro .
    if v-subcodedt = no then do: message 'Редактирование запрещено!' view-as alert-box. return. end.
    find current sub-cod exclusive-lock .
    repeat on error undo,retry :
        if sub-cod.d-cod = "ecdivisg" and lookup(codcod,'0,msc') = 0 then do:
            update sub-cod.ccode with frame frm.
            if substr(sub-cod.ccode,1) <> codcod then do:
                message "Группа не совпадает с разделом шифров отраслей экономики" view-as alert-box.
                sub-cod.ccode = "msc".
                leave.
            end.
        end.
        else if sub-cod.d-cod = "ecdivisg" and lookup(codcod,'0,msc') > 0 then do:
            message 'Сначала заполните раздел шифров отраслей экономики' view-as alert-box.
            leave.
        end.
        else do:
            update sub-cod.ccode with frame frm.
            if sub-cod.ccode entered then do:
                if sub-cod.d-cod = "arptype" then run addrec.
            end.
        end.
        sub-cod.rdt = g-today .
        find first codfr where codfr.codfr = sub-cod.d-cod and codfr.code = sub-cod.ccode use-index cdco_idx no-lock no-error .
        if avail codfr then leave .
        else undo,retry .
    end.
end.

procedure fnew.
    for each sub-dic where sub-dic.sub = v-sub no-lock .
        find first sub-cod where sub-cod.acc = v-acc and sub-cod.sub = v-sub and sub-cod.d-cod = sub-dic.d-cod use-index dcod  no-lock no-error.
        if not avail sub-cod then do transact:
            create sub-cod.
            sub-cod.acc = v-acc.
            sub-cod.sub = v-sub.
            sub-cod.d-cod = sub-dic.d-cod.
            if sub-dic.d-cod = "urgency" then sub-cod.ccode = 'o'.
            else sub-cod.ccode = 'msc'.
            cur = recid(sub-cod).
        end.
    end.
end procedure.

procedure addrec:
    create hissc.
    hissc.acc = sub-cod.acc.
    hissc.sub = sub-cod.sub.
    hissc.d-cod = sub-cod.d-cod.
    hissc.ccode = sub-cod.ccode.
    hissc.rdt = sub-cod.rdt.
    hissc.rcode = sub-cod.rcode.
    hissc.who = g-ofc.
    hissc.tim = time.
end procedure.

