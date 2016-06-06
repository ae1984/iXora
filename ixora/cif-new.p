/* cif-new.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        setup new account from cif
 * RUN
        верхнее меню "ОткрСч"
 * CALLER

 * SCRIPT

 * INHERIT
        cif-new2.p
 * MENU
        1.2
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
           st-period - период выписки всегда равен 0
   13.06.01 - при удалении счета проверяются записи в таблице sub-cod
   04.12.01 - добавлено меню - оплата за откр счета - делается запись в таб-цу bxcif,
              в таб-це ааа : поле vip   - код оплаты, (1- со счета, 2-льготный,
                                                       3- оплата налом, 4- бесплатно )
                                  penny - сумма комисии
   01.07.02 - проверка соответствия ЕКНП клиента группе счетов при открытии нового счета
   17/04/03  nataly  - была добавлена процедура cif-new2  и строка по удалению записи aaa , если aaa.cif = ""
   28/08/03 nataly  - Добавлена возможность запроса по клиенту в случае схемы 4 (по депозитам).
   11.03.04 nataly добавлена обработка признака для автоматической пролонгации депозита (схема 5)
   22.04.04 kanat - подправил коментарий в комментарии чтобы не нервировать будущих поколений программистов
   29.04.04 dpuchkov добавил отображение договоров при открытии счёта
   20.05.04 dpuchkov изменение формата отображения договора.
   02.06.04 dpuchkov вынес пути к каталогам в sysc и исключил договора для депозитных счетов.
   21.06.04 nadejda - в случае схемы 4 для признака капитализации процентов исправлено нажатие на кнопку 2
   23.11.04 dpuchkov - изменил размер фрейма для LGR = 18
   25.03.05 nataly - добавили проверку на aaa.lstmdt if aaa.lstmdt = ? then delete aaa.
   11.04.05 dpuchkov - изменил проверку пролонгировать/не пролонгировать для счетов схемы 7
   04.26.05 dpuchkov - добавил проверку avail sub-cod иначе вылетает при открытии счета.
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
   22.07.08 id00004 - добавил договора по депозитам метрошка и пенсионный
   15/08/08 marinav - проставить исключения по группе 246 aaa.lgr = 246
   12/03/09 marinav - проверка клиента на специнструкции
   15.04.2009 galina - добавила глобальную переменную v-aaa9
   16.04.2009 galina - перекомпеляция
                       при удалении 20-ти значного счета очищаем поле ааа20 для соотвествующего 9-ти значного счета
   08.09.09 marinav - добавлен признак - действующий налогоплательщик
   28.10.09 marinav - добавлен список групп, по которым не проверять наличие инкассовых
   12/11/2009 galina - добавила запись в лог при закрытии счета
   7.12.09   marinav - для нерезидентов физ лиц не проверять рнн
   31.03.2010 marinav - проверять на бездействующего налогоплательщика только юр лицо
   26.07.2010 marinav - для нерезидентов юр лиц не проверять рнн
   05/08/2010 aigul - проверка данных о клиентах связанных с банком особыми отношениями
   04/11/2010 galina - проверяем заполнение данных по первому руководителю
   09.12.10  marinav - для ИП убрана проверка на ecdivis
   19/01/2011 evseev - изменил &#179 на &#1179 (к - казахская)
   01.03.2011 marinav - изменение справочника ecdivis
   10.03.2011 ruslan - проверка учредителей и доли(%)
   11.03.2011 ruslan - добавил в проверку учредителей проверку на ИП
   14.03.2011 ruslan - изменил проверку в случае двух и более учредителей.
   11.04.2011 evseev - запрет открытия депозитов по группе A19,A20,A21,A25,A26,A27,A31,A32,A33,A34,A35,A36,484,485,486,487,488,489
   20.05.2011 evseev - запрет открытия депозитов по группе A22,A23,A24 до 1.06.2011
   26.05.2011 evseev - договора для lgr.feensf = 6
   10.06.2011 aigul - проверка срока действия УЛ
   11/07/2011 evseev - тз-1105. печать новых договоров по деп. и тек.счетам
   01/08/2011 evseev - подтягивать печать и подпись для определенных СП-шек
   02.08.2011 aigul - исправила message на "Не заполнено поле"
   03/08/2011 evseev - добавил новое значение в отчет и исправил ошибку вывода счета оврдрафта в отчет
   05/08/2011 evseev - реализация тз-1127
   12/08/2011 evseev - реализация ТЗ-1128
   17/08/2011 evseev - небольшие исправления
   19/08/2011 evseev - округление эфф.ставки до десятых знаков. Письмо от Исайкина А.
   22/08/2011 lyubov - проверка на наличие ОКПО. Если ОКПО отсутствует - вывод сообщения, выход из програмы
   23/08/2011 lyubov - исправила
   24/08/2011 lyubov - изменила проверку на физ.\юр. признак
   31/08/2011 evseev - тз-1063. при открытии депозита по ФЛ создавать проводку в кассу
   01/09/2011 evseev - логирование. при вопросе о создании проводки отправлять уведомление мне на почту.
   02/09/2011 evseev - добавил 3 валюты
   07/10/2011 evseev - переход на ИИН/БИН
   11/10/2011 id00004 - добавил группу 249
   17/10/2011 evseev - исправил ошибку в 218стр
   01.02.2012 lyubov - изменила символ кассплана (110 на 020)
   06/02/2012 dmitriy - добавил разбивку по группам счетов на юр/физ и од и остальные (ТЗ 1076)
   07/02/2012 dmitriy - изменил выбор M или L при открытии счета
   28.03.2012 Lyubov - нельзя открыть счет, если не проставлено значение справочника ecdivisg
   30.03.2012 Lyubov - внесла коррективы для справочников ecdivis и ecdivisg
   30.03.2012 id00810 - добавила v-bicbank, v-namebank для печати договоров
   30.03.2012 Lyubov - нельзя открыть счет, если не проставлено значение справочника ecdivisg
   24/04/2012 evseev - rebranding
   25/04/2012 evseev - повтор
   26/04/2012 evseev - повтор
   03/05/2012 evseev - nbankBik.i
   30.05.2012 damir  - keyord.i,отмена печати vou_bank2.p.
   30.05.2012 evseev - проверка бездействующих налогоплательщиков из inacttaxpayer
   31/05/2012 dmitriy - добавил проверку на заполненность поля "Орган выдачи уд.л. руководителя"
                      - поля с информацией о гл.бухе не проверяются, если значение поля "гл.бух" = " не предусмотрен"
   06/06/2012 dmitriy - удалил pause из проверки поля "Орган выдачи уд.л. руководителя"
   20/06/2012 id00810 - добавлен договор текушего счета по ПК
   19.07.2012 damir   - поправил сохранение данных по удост.личности в поле joudoc.passp.
   17/08/2012 Luiza   - добавила возможность вносить наличность на депозит через 100500
   28/08/2012 id00810 - перекомпиляция
   25.10.2012 evseev - ТЗ-1511
   04.12.2012 evseev - перекомпиляция
   05.12.2012 id00810 - ТЗ 1470 добавлен договор текушего счета по ПК для ЮЛ
   18.01.2013 dmitriy - ТЗ 1654 отмена проверки заполнения поля ОКПО
   22.01.2013 Lyubov  - ТЗ 1574, изменена и перенесена проверка открытия счета по бездействующим налогоплательщикам
   30.01.2013 evseev - tz-1646
   09.04.2013 evseev - tz-1678
   13.05.2013 evseev - tz-1828
   23.05.2013 evseev - tz-1844
   10/06/2013 galina - ТЗ 1822
   11.06.2013 evseev - tz-1845
   05/08/2013 Luiza  - ТЗ 1728 проверка клиентов связан-х с банком
   19/09/2013 Luiza  - ТЗ 1609 онлайн-запрос в AML
*/

{global.i}
{chbin.i}
{nbankBik.i}
{keyord.i}
def var v-acclist as char.
def shared var s-cif like cif.cif.    /*!!!!!*/
def var v-aaa as char format "x(60)".
def var v-rnn as char.
def var vbin as char.
def new shared temp-table temp
    field bank as char format 'x(60)'
    field aaa  like bank.aaa.aaa
    field crc  as char
    field cif  like bank.aaa.cif
    field name like bank.aaa.name
    field bal  as decimal
    index main is primary cif aaa.


def var codcod as char.

{u-2-w.i}
{sysc.i}
def stream v-out.
def var v-ofile as char.
def var v-ifile as char.
def var v-clientname as char.
def var v-name as char.
def var v-iik as char.
def var v-str as char.
def var v-sys as char.
def var v-rez as log init yes.

def var v-aaacif like aaa.aaa.
def new shared var s-aaa like aaa.aaa.
def new shared var s-lgr like lgr.lgr.
def new shared  Variable V-sel As Integer FORMAT "9" init 1.
def  new shared var in_command as decimal .
def  new shared  var v-rate as decimal.
def new shared var v-aaa9 as char.
def var v-log as log init no.
def new shared var p-typ like cif.type.
def new shared var p-dep as char format "x(1)".

def var ans as log.
def var v-lgr like lgr.lgr.
def var vans as log.
def new shared  variable st_period as integer initial 30.
def new shared var opt as cha format "x(1)".
def new shared var s-okcancel as logical initial False.

def var v-lgrwrong as log init false.
def var s-accont as char.
def var l-ShowContract as logical.
def buffer b-aaa for aaa.
def buffer b-cif for cif.
def buffer buf-aaa for aaa.
def buffer buf-aaa1 for aaa.
/*galina*/
def stream aaaclsofc.
def var vfilecls as char.
def var v-bank as char.
def var v-ans as logi.
def var v-ans1 as logi.
def var v-aaa1 like aaa.aaa.

def var ch as char.
def var mathilda as logi init false.

def var v-garnum like garan.garnum.
def var v-gardt as char.
def var v-ref   as char no-undo.
def var v-listfio  as char no-undo.
def var v-doly  as decim no-undo.
def var v-errorDes    as char no-undo.
def var v-operId      as char no-undo.
def var v-operStatus  as char no-undo.
def var v-operComment as char no-undo.
def temp-table wupl
    field fio as char.

find first cif where cif.cif = s-cif no-lock no-error.
if cif.type = 'B' or cif.type = 'b' then do:
/*if cif.ssn = '' or cif.ssn = '000000000' or cif.ssn = '00000000' or cif.ssn = '0000000' or cif.ssn = '000000' or cif.ssn = '00000' or cif.ssn = '0000' or cif.ssn = '000' or cif.ssn = '00' or cif.ssn = '0'
then mathilda = true.*/
end.

/* Luiza --------------------*/
def var v-ek as integer no-undo.
def new shared var v-nomer like cslist.nomer no-undo.
def var v-crc_val as char no-undo.
def var v-rr as char.
def var v-chEK as char format "x(20)". /* счет ЭК*/
def temp-table tmprez
field des as char.
create tmprez. tmprez.des = "1. Касса (100100)".
create tmprez. tmprez.des = "2. Электронный кассир (100500)".
DEFINE QUERY q-rez FOR tmprez.
DEFINE BROWSE b-rez QUERY q-rez
       DISPLAY tmprez.des label "Выберите тип оплаты: " format "x(30)" WITH  2 DOWN overlay.
DEFINE FRAME f-rez b-rez  WITH overlay 1 COLUMN SIDE-LABELS row 25 COLUMN 40 width 40.

def var v-select as int.

on "END-ERROR" of frame f-rez do:
  hide frame f-rez no-pause.
  undo,return.
end.
/*-----------------------*/

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
/* aigul - проверка данных о клиентах связанных с банком особыми отношениями */
def var v-resp as int.
run bnkrel-chk.
v-resp = 0.
run bnkrel-chk1(s-cif,output v-resp).
if v-resp > 0 then return.
/*
find first sub-cod where sub-cod.d-cod = "bnkrel" and sub-cod.acc = s-cif no-lock no-error.
if avail sub-cod then do:
if sub-cod.ccode = '' or sub-cod.ccode = 'msc' then do:
    message "У данного клиента не проставлен признак 'лица связанные с банком особыми отношениями'. Открытие счета невозможно!" view-as alert-box error.
    return.
end.
end.
else do:
    message "У данного клиента не проставлен признак 'лица связанные с банком особыми отношениями'. Открытие счета невозможно!" view-as alert-box error.
    return.
end.
*/
/************************************************************************************/

/* онлайн-запрос в AML */
do transaction:
    v-listfio = "".
    if can-do("B,b,P,p",trim(cif.type)) then do:
        find first cmp no-lock no-error.
        find first codfr where codfr.codfr = "" no-lock no-error.
        /* первый руков */
        find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and  sub-cod.d-cod = 'clnchf' and sub-cod.ccode = 'chief' no-lock no-error.
        if avail sub-cod then v-listfio = v-listfio + trim(sub-cod.rcode) + "|".
        /* по учередителям */
        for each founder where founder.cif = s-cif no-lock.
            v-doly = 0.
            v-doly = decim(founder.reschar[1]) no-error .
            if v-doly >= 25 then do:
                if v-listfio = "" then v-listfio = trim(founder.name) + "|".
                else v-listfio = v-listfio + trim(founder.name) + "|".
            end.
        end.
        /* по доверенным лицам */
        for each uplcif where uplcif.cif = s-cif and uplcif.finday > g-today.
            find first wupl where wupl.fio = uplcif.badd[1] no-lock no-error.
            if not available wupl then do:
                create wupl.
                wupl.fio = uplcif.badd[1].
            end.
        end.
        for each wupl no-lock.
            if v-listfio = "" then v-listfio = trim(wupl.fio) + "|".
            else v-listfio = v-listfio + trim(wupl.fio) + "|".
        end.

        v-ref = cif.cif + "_" + substr(string(year(g-today)),3,2) + string(month(g-today),'99') + string(day(g-today),'99').
        run kfmAMLOnline(v-ref, /* номер операции: cif_дата */
                     "",  /*страна*/
                     cif.name,   /*ФИО*/
                     v-listfio,
                     '1',
                     '1',
                     "",
                     "",
                     "",
                     output v-errorDes,
                     output v-operId,
                     output v-operStatus,
                     output v-operComment).
        pause 0.
        if trim(v-errorDes) <> '' then do:
            message "Ошибка!~n" + v-errorDes + "~nПри необходимости обратитесь в ДИТ" view-as alert-box title 'ВНИМАНИЕ'.
            return.
        end.
        if v-operStatus = '0' then do:
            message "Проведение операции приостановлено! Данные клиента отправлены на проверку в службу Комплаенс!" view-as alert-box information buttons ok title ' Внимание! '.
            run mail("cs@fortebank.com", g-ofc + "@fortebank.com", "Необходима проверка клиента",
            "Открытие счета, произошло совпадение со справочником ИПДЛ/Террорист " + cmp.name + " Менеджер " + g-ofc +
            " cif код: " + cif.cif + " ФИО/Наименование лица: " + cif.name + " " + v-listfio,"1", "","").
            return.
        end.

        if v-operStatus = '2' then do:
            message "Проведение операции запрещено службой Комплаенс!"  + "~n Счет не может быть открыт!" view-as alert-box title ' Внимание! '.
            find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
                and sub-cod.d-cod = "pep/terr" exclusive-lock no-error.
            if avail sub-cod then sub-cod.ccode = "02".
            else do:
                create sub-cod.
                sub-cod.acc = s-cif.
                sub-cod.sub = "cln".
                sub-cod.d-cod = "pep/terr".
                sub-cod.ccode = "02".
            end.
            find current sub-cod no-lock no-error.
            return.
        end.
    end.
end.
/*конец - проверка на терроризм*/

{print-dolg.i}
v-acclist = "".

find first cif where cif.cif = s-cif no-lock no-error.
if cif.type = "P" and cif.doctype = "" then do transaction:
   run sel2 (" Тип документа", "01-Удостов. личности гражданина РК |02-Паспорт гражданина РК  |04-Вид на жительство иностранца в РК |05-Удостов. лица без гражданстра ", output v-select).
   find first b-cif where b-cif.cif = cif.cif exclusive-lock no-error.
   if avail b-cif then do:
      if v-select = 1 then b-cif.doctype = '01'.
      else if v-select = 2 then b-cif.doctype = '02'.
      else if v-select = 3 then b-cif.doctype = '04'.
      else if v-select = 4 then b-cif.doctype = '05'.
      find current b-cif no-lock no-error.
   end. else do:
      message "Не найден клиент [1]" view-as alert-box.
      return.
   end.
end.


{desp.i 0401 18 opt}
{comm-txb.i}
v-ans = false.
if opt eq "N" then do:
   repeat:
        find first cif where cif.cif = s-cif no-lock no-error.

        find first fakecompany where fakecompany.bin = cif.bin no-lock no-error.
        if avail fakecompany then do:
            message "Данный ИИН/БИН находится в списке лжепредприятий! Счет не может быть открыт!" view-as alert-box.
            return.
        end.


        v-rnn = cif.bin.
        find first rnn where rnn.bin = v-rnn no-lock no-error.
        if not avail rnn then do:
            find first rnnu where rnnu.bin = v-rnn no-lock no-error.
            if not avail rnnu then do:
                message "Данный ИИН/БИН отсутствует в НК МФ ! Счет не может быть открыт!" view-as alert-box.
               return.
            end.
            else do:
                if rnnu.activity = '1' then do:
                    message "Налогоплательщик является бездействующим ! Счет не может быть открыт! [1]" view-as alert-box.
                    return.
                end.
            end.
        end.
        else do:
            if rnn.info[2] = '1' and rnn.info[5] = '1' then do:
               message "Налогоплательщик является бездействующим ! Счет не может быть открыт! [1]" view-as alert-box.
               return.
            end.
            if rnn.info[4] > '0' and rnn.info[5] = '1' then do:
               message "Налогоплательщик является бездействующим ! Счет не может быть открыт! [1.1]" view-as alert-box.
               return.
            end.
        end.

        p-typ = cif.type.

        {desp.i 10001 18 p-dep}
        run h-lgr(output v-lgr).


        {desp.i 9838 18 v-lgr}

        s-lgr = frame-value.
        s-lgr = caps(s-lgr).
        find lgr where lgr.lgr eq s-lgr.

        /*ch = substring(string(lgr.gl), 1, 4).
        if ch = '2203' then do:
            if mathilda <> false then do:
                message ' Не заполнено поле ОКПО ! ' view-as alert-box title 'ВНИМАНИЕ'.
                leave.
            end.
        end.*/

        find led where led.led eq lgr.led.
        find crc where crc.crc = lgr.crc no-lock.

        find first cif where cif.cif = s-cif no-lock no-error.
        v-rnn = cif.jss.
        vbin = cif.bin.

        if v-bin then do:
           if trim(vbin) = "" and lookup(lgr.led,"TDA,CDA") <> 0 then v-rez = no.
        end. else do:
           if trim(v-rnn) = "" and lookup(lgr.led,"TDA,CDA") <> 0 then v-rez = no.
        end.

        if lookup(lgr.lgr,"A28,A29,A30,A13,A14,A15") <> 0 then do:
           message "С 01.06.08 ЗАПРЕЩЕНО открывать депозит по данной группе" view-as alert-box .
           /*pause.*/
           return.
        end.

        if lookup(lgr.lgr,"A22,A23,A24,A38,A39,A40") <> 0 then do:
           if g-today < 06/01/11 then do:
              message "ДО 01.06.11 ЗАПРЕЩЕНО открывать депозит по данной группе" view-as alert-box .
              return.
           end.
        end.

        if lookup(lgr.lgr,"A19,A20,A21,A25,A26,A27,A31,A32,A33,A34,A35,A36") <> 0 then do:
           message "С 11.04.2011 ЗАПРЕЩЕНО открывать депозит по данной группе" view-as alert-box .
           return.
        end.

        if lookup(lgr.lgr,"484,485,486,487,488,489") <> 0 then do:
           message "С 11.04.2011 ЗАПРЕЩЕНО открывать депозит по данной группе" view-as alert-box.
           return.
        end.

        if lookup(lgr.lgr,"A22,A23,A24,A01,A02,A03,A04,A05,A06") > 0 then do:
           message "С 22.05.2013 ЗАПРЕЩЕНО открывать депозит по данной группе" view-as alert-box.
           return.
        end.

        if lookup(lgr.lgr,"478,479,480,481,482,483") <> 0 then do:
           message "С 10.06.2013 ЗАПРЕЩЕНО открывать депозит по данной группе" view-as alert-box.
           return.
        end.

        if lookup(lgr.lgr,"B09,B10,B11") <> 0 then do:
           if g-today < 06/24/13 then do:
              message "ДО 24.06.13 ЗАПРЕЩЕНО открывать депозит по данной группе" view-as alert-box .
              return.
           end.
        end.
        if lookup(lgr.lgr,"B15,B16,B17,B18,B19,B20") <> 0 then do:
           if g-today < 07/15/13 then do:
              message "ДО 15.07.13 ЗАПРЕЩЕНО открывать депозит по данной группе" view-as alert-box .
              return.
           end.
        end.

        if lookup(lgr.lgr,"453,455,456,457,458,459,460,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,477,491,492,493,494,495,496,497,498,499") = 0 then do:
             def var v-s as char no-undo.
             if v-bin then v-s = vbin. else v-s = v-rnn.
             {r-branch.i &proc = "cifnk(v-s)"}

              v-aaa = ''.
              for each temp.
                 v-aaa = v-aaa + temp.aaa + " " + temp.crc + ", " .
              end.
              find first temp no-lock no-error.
              if v-aaa ne "" then do:
                    message "Данный РНН уже существует. Клиент: " + temp.name + ", код: "  temp.cif +
                                  " в " + temp.bank + ". Счета " + v-aaa +
                                  " заблокированы инкассовыми распоряжениями/предписаниями налоговых органов, дополнительный счет не может быть открыт!" view-as alert-box .
                    return.
              end.
        end.


        if cif.type = 'B' and cif.cgr <> 403 then do:
            find first founder where founder.cif = s-cif no-lock no-error.
            if not avail founder then do:
                message "Не указан(ы) учредитель(и). Нельзя открыть счет" view-as alert-box info.
                return.
            end.
            else do:
                for each founder where founder.cif = s-cif no-lock:
                    if founder.reschar[1] = '' or decimal(founder.reschar[1]) < 0 then do:
                        message "Не указана доля учредителя(ей). Нельзя открыть счет" view-as alert-box info.
                        return.
                    end.
                end.
            end.
        end.
        if cif.type = 'P' and cif.dtsrokul = ? then do:
            message "Не заполнено поле - Срок действия УЛ !" view-as alert-box.
        end.

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

        find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
            and sub-cod.d-cod = "secek" no-lock no-error.
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
           codcod = substr(sub-cod.ccode,1).
           message "Неверное значение раздела отрасли экономики клиента - msc. Невозможно открыть счет." view-as alert-box.
           return.
        end.
        else codcod = sub-cod.ccode.

        if not ((lgr.tlev = 1 and
                   ((int(sub-cod.ccode) >= 1 and int(sub-cod.ccode) <= 99))) /* юр лицо */ or
                (lgr.tlev = 2 and int(sub-cod.ccode) = 0) /* физ лицо */ or
                (lgr.tlev = 3 /*and int(sub-cod.ccode) = 98*/) /* ЧП */ ) then do:
           message "Отрасль экономики клиента не соответствует типу клиентов для этой группы счетов. Нельзя открыть счет.".
           pause.
           v-lgrwrong = true.
        end.

        find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif and sub-cod.d-cod = "ecdivisg" no-lock no-error.
        if codcod <> '0' and (not avail sub-cod or sub-cod.ccode = 'msc') then do:
           message "Неверное значение группы/класса отрасли экономики клиента - msc. Невозможно открыть счет." view-as alert-box.
           return.
        end.

        run check_ul(cif.cif).

        if cif.type = 'B' and cif.cgr <> 403 then do:
            find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
                and sub-cod.d-cod = "clnchfpl" no-lock no-error.
            if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
               message "Не заполнено поле Орган выдачи уд.л. первого руководителя (признак clnchfpl)." view-as alert-box.
               v-lgrwrong = false.
            end.

            find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif and sub-cod.d-cod = "clnbk" no-lock no-error.
            if avail sub-cod and sub-cod.rcode <> 'не предусмотрен' then do:
                find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
                    and sub-cod.d-cod = "clnbkdt" no-lock no-error.
                if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
                   message "Не заполнено поле дата выдачи УЛ гл.бухгалтера (признак clnbkdt)." view-as alert-box.
                   v-lgrwrong = false.
                end.
                find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
                    and sub-cod.d-cod = "clnbknum" no-lock no-error.
                if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
                   message "Не заполнено поле номер УЛ гл.бухгалтера (признак clnbknum)." view-as alert-box.
                   v-lgrwrong = false.
                end.
                find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
                    and sub-cod.d-cod = "clnbkpl" no-lock no-error.
                if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
                   message "Не заполнено поле орган выдачи УЛ бухгалтера (признак clnbkpl)." view-as alert-box.
                   v-lgrwrong = false.
                end.
                find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
                    and sub-cod.d-cod = "clnbkdtex" no-lock no-error.
                if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
                   message "Не заполнено поле срок действия УЛ бухгалтера (признак clnbkdtex)." view-as alert-box.
                   v-lgrwrong = false.
                end.
            end.

            find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
                and sub-cod.d-cod = "clnchfddtex" no-lock no-error.
            if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
               message "Не заполнено поле срок действия УЛ директора (признак clnchfddtex)." view-as alert-box.
               v-lgrwrong = false.
            end.
            find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
                and sub-cod.d-cod = "clnchfrnn" no-lock no-error.
            if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
               message "Не заполнено поле РНН первого руководителя (признак clnchfrnn). Нельзя открыть счет.".
               pause.
               v-lgrwrong = true.
            end.

            find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
                and sub-cod.d-cod = "clnchfddt" no-lock no-error.
            if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
               message "Не заполнено поле дата выдачи уд.л. первому руководителю (признак clnchfddt). Нельзя открыть счет.".
               pause.
               v-lgrwrong = true.
            end.

            find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
                and sub-cod.d-cod = "clnchfdnum" no-lock no-error.
            if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
               message "Не заполнено поле номер уд.л. первого руководителя (признак clnchfdnum). Нельзя открыть счет.".
               pause.
               v-lgrwrong = true.
            end.

            find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
                and sub-cod.d-cod = "lnopf" no-lock no-error.
            if not avail sub-cod or sub-cod.ccode = "msc" then do:
               message "Не заполнено поле Организационно-правовая форма хозяйствования (признак lnopf). Нельзя открыть счет.".
               pause.
               v-lgrwrong = true.
            end.

        end.

        if cif.type = 'B' then do:
            find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
               and sub-cod.d-cod = "clnchfd1" no-lock no-error.
            if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
               message "Не заполнено поле Должность руководителя предприятия (признак clnchfd1). Нельзя открыть счет.".
               pause.
               v-lgrwrong = true.
            end.
        end.


        if v-lgrwrong then
           return.

        if crc.sts = 9 then do:
           message "Невозможно открыть счет, валюта " + crc.code + " закрыта.".
           pause.
           return.
        end.

        if keyfunction(lastkey) eq "GO" or keyfunction(lastkey) eq "RETURN"
        then do trans on error undo, retry:
               {mesg.i 1808} update ans.
               if ans eq false then return.

               if lgr.nxt eq 0 then do:
                 {mesg.i 1812} update s-aaa.
               end.
               else do:
                 run new-acc.
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

                     find last sub-cod where sub-cod.acc = s-aaa and sub-cod.sub = 'CIF' exclusive-lock no-error.
                     if not avail sub-cod then create sub-cod.
                               sub-cod.acc = s-aaa.
                               sub-cod.sub = 'CIF'. sub-cod.d-cod = 'prlng'.
                               if prz2 = 1 then sub-cod.ccod = 'yes'. else  sub-cod.ccod = 'no'.
                               sub-cod.rdt = g-today.
                  end.

               end.
        end.

        v-aaa1 = s-aaa.
        find last aaa where /*aaa.cif = s-cif*/ aaa.aaa = v-aaa1 no-lock no-error.
        if avail  aaa then l-ShowContract = False. else l-ShowContract = True.


        run  cif-new2.
        do trans on error undo, retry:
               find aaa where aaa.aaa = s-aaa  exclusive-lock no-error.
               if avail  aaa and aaa.cif = "" then  delete aaa.
               if avail  aaa and lgr.led = "TDA" and aaa.lstmdt = ? then delete aaa.
        end.
        if aaa.lgr = '246' then do trans on error undo, retry:
           run add-exc(s-aaa, s-cif, "193").
           run add-exc(s-aaa, s-cif, "180").
           run add-exc(s-aaa, s-cif, "450").
           run add-exc(s-aaa, s-cif, "429").
           run add-exc(s-aaa, s-cif, "181").
           run add-exc(s-aaa, s-cif, "419").
           /*run doggcvp.*/
        end.


        find last crc where crc.crc = aaa.crc no-lock no-error.
        find last cmp no-lock no-error.
        /* Формирование договора и отображение в html в зависимости от типа предпринимателя */
        /*  if s-okcancel = True then */
        def var vr-mes as char.
        def var vk-mes as char.

        def var vr-period as char.
        def var vk-period as char.

        run defdts(g-today, output vr-mes, output vk-mes).
        run defdts1(aaa.regdt, aaa.expdt, output vr-period, output vk-period).

        def var v-podp as char.
        def var v-bickfiliala as char.
        def var v-bickfilialakz as char.
        find last cmp no-lock no-error.
        def buffer bss for sysc.
        def buffer bmm for sysc.
        find last bmm where bmm.sysc = "OURBNK" no-lock no-error.
        if bmm.chval = "TXB00" then v-podp = "Бояркина И.Я.".

        find bss where bss.sysc = "bnkadr" no-lock no-error.
        if num-entries(bss.chval,"|") > 13 then
            v-bickfilialakz = entry(14, bss.chval,"|") + ", " .
            v-bickfilialakz = v-bickfilialakz + "СТТН " + cmp.addr[2] + ", ЖИК " + get-sysc-cha ("bnkiik") + ", БСК " + get-sysc-cha ("clecod") + ", " .

        if num-entries(bss.chval,"|") > 10 then
        v-bickfilialakz = v-bickfilialakz +  entry(11, bss.chval,"|").
        v-bickfiliala = cmp.name + ", " + "РНН " + cmp.addr[2] + ", ИИК " + get-sysc-cha ("bnkiik") + ", БИК " + get-sysc-cha ("clecod") + ", " + cmp.addr[1].

        if bmm.chval = "TXB00" then v-bickfilialakz = "".
        if bmm.chval = "TXB00" then v-bickfiliala = "".

        find last bss where bss.sysc = "DKPODP" no-lock no-error.
        v-podp = bss.chval.
        def buffer bcit for sysc.
        def var v-city as char no-undo.
        find last bcit where bcit.sysc = "citi" no-lock no-error.
        if avail bcit then v-city = bcit.chval.
        def buffer bkcit for sysc.
        def var v-kcity as char no-undo.
        find last bkcit where bkcit.sysc = "kcity" no-lock no-error.
        if avail bkcit then v-kcity = bkcit.chval.
        else v-kcity = v-city.

        if bmm.chval = "TXB00" then v-podp = "Бояркина И.Я.".

        v-ans = false.
        if lookup(lgr.lgr,"202,204,222,208,151,153,171,157,176,152,154,172,158,177,173,175,174,249") > 0  then
           message "Открыть доп. счет?"  view-as alert-box question buttons yes-no title "" update v-ans.

        find last buf-aaa1 where buf-aaa1.aaa = v-aaa1 /*(buf-aaa1.cif = s-cif) and (lookup(buf-aaa1.lgr,"A22,A23,A24,A01,A02,A03,A04,A05,A06,246,478,479,480,481,482,483,518,519,520,151,153,171,157,176,152,154,172,158,177,173,175,174,202,204,222,208") > 0)*/ no-lock no-error.
        if v-acclist <> "" then v-acclist = v-acclist + ",".
        if avail buf-aaa1 then do:
           v-acclist = v-acclist + buf-aaa1.aaa.
        end.

        run savelog('cif-new',"654. " + cif.cif + " " +  buf-aaa1.aaa + " " + buf-aaa1.lgr + " " + cif.type + " " + cif.geo).
        if (cif.type = "p" and cif.geo = '022' and lookup(buf-aaa1.lgr,"202,204,222,208,249,246,247,248,138,139,140") > 0) or
           (cif.type = "p" and cif.geo = '021') then do:
            if caps(cif.type) = "P" and (rnn.info[2] = "1" or rnn.info[4] = "1" or rnn.info[4] = "2" or rnn.info[4] = "3" or rnn.info[4] = "4") then do:
               run mail("id00787@metrocombank.kz", "ACC <acc@metrocombank.kz>",
                   "Клиент состоит на регистрационном учете.",
                   "Клиент " + cif.cif + " " + trim(cif.name) + " " +  buf-aaa1.aaa + " состоит на регистрационном учете. Необходимо проверить формирование уведомления в НК",
                   "", "", "").

               find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
               if avail sysc then
                  run mail(entry(5, sysc.chval, "|"), "ACC <acc@metrocombank.kz>",
                   "Клиент состоит на регистрационном учете.",
                   "Клиент " + cif.cif + " " + trim(cif.name) + " " +  buf-aaa1.aaa + " состоит на регистрационном учете. Необходимо проверить формирование уведомления в НК",
                   "", "", "").
            end.
        end.

            def var v-fo as char.
            def var v-fam as char.
            def var v-nam as char.
            def var v-otch as char.
            def var v-acla as char.
            def var v-kacla as char.
            def var v-sumopnam as char.
            def var v-ksumopnam as char.
            def var v-rastr as char.
            def var v-rnost as char.
            def var v-knost as char.
            def var v-tmpstr as char.
            def var v-tmpstr1 as char.
            def var v-kazaddr as char.
            def var i as int.
            def var v-tmpstrlist as char.
            def var v-tmpstrlist1 as char.

            def var v-kval as char.
            def var v-rval as char.

            def var v-kdd as char.
            def var v-rdd as char.
            def var v-kmm as char.
            def var v-rmm as char.
            def var v-kddmm as char.
            def var v-rddmm as char.
            def var v-otvlico as char.

            def  var vpoint like point.point .
            def  var vdep like ppoint.dep .
            def  var v-prefix as char.
            def var v-ipsvidrus as char.
            def var v-ipsvidkz as char.
            def var v-binrus as char.
            def var v-binkz as char.
            def var v-stamp as char.
            def var v-dogsgn as char.


        if (v-ans = false) and (lookup(lgr.lgr,"B15,B16,B17,B18,B19,B20,B09,B10,B11,B01,B02,B03,B04,B05,B06,B07,B08,A38,A39,A40,A22,A23,A24,A01,A02,A03,A04,A05,A06,246,478,479,480,481,482,483,518,519,520,151,153,171,157,176,152,154,172,158,177,173,175,174,202,204,222,208,249,138,139,140,143,144,145") > 0)  then do:
            if lookup(lgr.lgr,"A38,A39,A40,A22,A23,A24,A01,A02,A03,A04,A05,A06") > 0  then do:
               v-ans1 = false.
               message "Создать проводку?"  view-as alert-box question buttons yes-no title "" update v-ans1.
               if v-ans1 then run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "Сделать проводку в кассу?",
                              " ДА " + string(lgr.lgr) + "; " + string(buf-aaa1.aaa), "1", "", "").
               else if v-ans1 then run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "Сделать проводку в кассу?",
                    " НЕТ " + string(lgr.lgr) + "; " + string(buf-aaa1.aaa), "1", "", "").

               def var v-tmpl as char no-undo.
               def new shared var s-jh like jh.jh.
               def var v-param as char no-undo.
               def var vdel as char no-undo initial "^".
               def var rcode as int no-undo.
               def var rdes as char no-undo.
               def new shared var v_doc as char.
               def var v-geo as char no-undo.
               def var v-chk as char no-undo.
               if  v-ans1 then do transaction:
                    if cif.geo = "021" then v-geo = "1".
                    if cif.geo = "022" then v-geo = "2".

                    /* Luiza**************************************************************************/
                    v-ek = 0.
                    OPEN QUERY  q-rez FOR EACH tmprez no-lock.
                    ENABLE ALL WITH FRAME f-rez.
                    wait-for return of frame f-rez
                    FOCUS b-rez IN FRAME f-rez.
                    v-ek = int(substring(tmprez.des,1,1)).
                    hide frame f-rez.
                    if keyfunction (lastkey) = "end-error" then next.
                    if (v-ek < 1) or (v-ek > 2) then next.
                    if v-ek = 2 then do:
                        find first csofc where csofc.ofc = g-ofc no-lock no-error.
                        if not avail csofc then do:
                            message "Нет привязки к ЭК!" view-as alert-box error.
                            next.
                        end.
                        else do:
                            find first codfr where codfr.codfr = 'ekcrc' and codf.code = string(buf-aaa1.crc) no-lock no-error.
                            if not avail codfr then do:
                                message "Не допустимый код валюты для работы с ЕК! Используйте счет 100100." view-as alert-box error.
                                next.
                            end.

                            find first codfr where codfr.codfr = 'limek' and codfr.code = string(buf-aaa1.crc) no-lock no-error.
                            if not avail codfr then do:
                                message "В справ-ке <codfr> отсутствует запись суммы лимита для данной валюты по ЭК!~nОбратитесь к администратору АБС!" view-as alert-box error.
                                next.
                            end.
                            else do:
                                if buf-aaa1.opnamt > decim(trim(codfr.name[1])) then do:
                                    find first crc where crc.crc = buf-aaa1.crc no-lock no-error.
                                    message "Ошибка, сумма превышает лимит суммы при работе с ЕК "  + trim(codfr.name[1]) + " " + crc.code  view-as alert-box error.
                                    next.
                                end.
                            end.

                            v-nomer = csofc.nomer.
                            find first crc where crc.crc = buf-aaa1.crc no-lock.
                            v-crc_val = crc.code.
                            v-chEK = "".
                            for each arp where arp.gl = 100500 and arp.crc = buf-aaa1.crc no-lock.
                                find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
                                if avail sub-cod then v-chEK = arp.arp.
                            end.
                            if v-chEK = '' then do:
                                message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crc_val + " !" view-as alert-box title " ОШИБКА ! ".
                                next.
                            end.

                            v-tmpl = "jou0046".
                            v-param = "" + vdel +
                                      string(buf-aaa1.opnamt) + vdel +
                                      string(buf-aaa1.crc) + vdel + /* валюта */
                                      v-chEK + vdel +
                                      buf-aaa1.aaa + vdel +
                                      "Взнос на депозит «" + lgr.des + "»" + vdel +
                                      v-geo + vdel + /* резидент/не резидент */
                                      "9" + vdel + /* сектор экономики - домашнее хоз-во */
                                      if buf-aaa1.gl = 220620 then "312" else "314". /* код назначения платежа */
                            v-param = v-param + vdel + string(buf-aaa1.opnamt).

                            s-jh = 0.
                            run trxgen (v-tmpl, vdel, v-param, "cif", buf-aaa1.aaa, output rcode, output rdes, input-output s-jh).

                            if rcode ne 0 then do:
                                message rdes.
                                pause 1000.
                                next.
                            end.
                        end. /* else do  */
                    end. /* v-ek = 2 then */
                    /* ---------------------------------------------------------------------------------***/
                    if v-ek = 1 then do:
                        v-tmpl = "jou0004".
                        v-param = "" + vdel +
                                  string(buf-aaa1.opnamt) + vdel +
                                  string(buf-aaa1.crc) + vdel + /* валюта */
                                  buf-aaa1.aaa + vdel +
                                  "Взнос на депозит «" + lgr.des + "»" + vdel +
                                  v-geo + vdel + /* резидент/не резидент */
                                  "9" + vdel + /* сектор экономики - домашнее хоз-во */
                                  if buf-aaa1.gl = 220620 then "312" else "314". /* код назначения платежа */
                        v-param = v-param + vdel + string(buf-aaa1.opnamt).

                        s-jh = 0.
                        run trxgen (v-tmpl, vdel, v-param, "cif", buf-aaa1.aaa, output rcode, output rdes, input-output s-jh).

                        if rcode ne 0 then do:
                            message rdes.
                            pause 1000.
                            next.
                        end.
                    end. /* v-ek = 1 then */

                    run jou. /* создадим jou-документ */
                    v_doc = return-value.
                    /* в программе jou по умолчанию проставляется статус rdy, в случае с ЭК не правильно, надо поменять на trx */
                    if v-ek = 2 then do:
                        find first substs where substs.sub = "jou" and substs.acc = v_doc exclusive-lock no-error.
                        if available substs then substs.sts = "trx".
                        find first substs where substs.sub = "jou" and substs.acc = v_doc no-lock no-error.

                        find first cursts where cursts.sub = "jou" and cursts.acc = v_doc exclusive-lock no-error.
                        if available cursts then cursts.sts = "trx".
                        find first cursts where cursts.sub = "jou" and cursts.acc = v_doc no-lock no-error.
                    end.
                    /* создадим запись joudop  */
                    create joudop.
                    joudop.docnum = v_doc.
                    joudop.who = g-ofc.
                    joudop.whn = g-today.
                    joudop.jh = s-jh.
                    joudop.tim = time.
                    if v-ek = 2 then joudop.type = "EK1". else joudop.type = "CS1".

                    find first jh where jh.jh = s-jh exclusive-lock.
                    jh.party = v_doc.

                    if jh.sts < 5 then jh.sts = 5.
                    for each jl of jh:
                        if jl.sts < 5 then jl.sts = 5.
                    end.
                    find current jh no-lock.

                    /*
                    run trxsts (input s-jh, input 6, output rcode, output rdes).
                    if rcode ne 0 then do:
                        message rdes.
                        pause 1000.
                        next.
                    end.
                    */
                    run setcsymb (s-jh, 020). /* проставим символ кассплана */

                    find first joudoc where joudoc.docnum = v_doc no-error.
                    if avail joudoc then do:
                       joudoc.info = trim(cif.name).
                       if num-entries(trim(cif.pss),",") > 1 or num-entries(trim(cif.pss)," ") <= 1 then joudoc.passp = trim(cif.pss).
                       else joudoc.passp = entry(1,trim(cif.pss)," ") + "," + substring(trim(cif.pss),index(trim(cif.pss)," "), length(cif.pss)).
                       joudoc.perkod = cif.jss.
                       joudoc.comcode = "302".
                       joudoc.rescha[1] = "1-1-2".
                       joudoc.comacctype = "1".
                    end.

                    create sub-cod.
                    sub-cod.acc = v_doc.
                    sub-cod.sub = "jou".
                    sub-cod.d-cod  = "eknp".
                    sub-cod.ccode = "eknp".
                    sub-cod.rdt = g-today.
                    sub-cod.rcode = v-geo + "9," + v-geo + "9,".
                    if buf-aaa1.gl = 220620 then sub-cod.rcode = sub-cod.rcode + "312".
                    else sub-cod.rcode = sub-cod.rcode + "314".

                    find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
                    if not avail acheck then do:
                        v-chk = "".
                        v-chk = string(NEXT-VALUE(krnum)).
                        create acheck.
                        assign acheck.jh  = string(s-jh)
                               acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk
                               acheck.dt = g-today
                               acheck.n1 = v-chk.
                        release acheck.
                    end.
                    if v-ek = 1 then MESSAGE "ПРОВОДКА СФОРМИРОВАНА, НОМЕР ТРАНЗАКЦИИ: " + string(s-jh) view-as alert-box.
                    if v-ek = 2 then MESSAGE "ПРОВОДКА СФОРМИРОВАНА, НОМЕР ТРАНЗАКЦИИ: " + string(s-jh) +
                                "~nНеобходимо отштамповать проводку в п.м. 15.2.1.2" view-as alert-box.



                    /* message " jh=" jh.jh " jou=" jh.party " " view-as alert-box buttons ok. */
                    if v-noord = no then run vou_bank2(3, 1, joudoc.info).  /*без вопросов печатать только операционный ордер*/

               end.  /* if  v-ans1 then*/
            end. /* if lookup(lgr.lgr,"A22,A23,A24,A01,A02,A03,A04,A05,A06") > 0 */


            find first ofc where ofc.ofc = g-ofc no-lock no-error.
            vpoint =  integer(ofc.regno / 1000).
            vdep = ofc.regno mod 1000.

            find ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock no-error.

            v-stamp = "".
            v-dogsgn = "".
            if avail ppoint and ppoint.name matches "*СП*" and ppoint.info[5] <> "" and ppoint.info[6] <> "" and ppoint.info[7] <> "" and aaa.sta <> "C" then do:
                 v-otvlico = "sp_" + string(ppoint.depart) + "_" + string("1").
                 v-stamp = "stamp_" + v-otvlico.
                 v-dogsgn = "dogsgn_" + v-otvlico.

                 find first codfr where codfr.code = v-otvlico no-lock no-error.
                 if not avail codfr or trim(codfr.name[1]) = "" then do:
                    v-stamp = "".
                    v-dogsgn = "".
                 end.
                 /*message v-otvlico. pause.*/
            end.
            else do:
                find first sysc where sysc.sysc = "otvlico" no-lock no-error.
                if avail sysc then v-otvlico = sysc.chval.
                else v-otvlico = "1".
            end.

            v-prefix = "sp_".
            /*
            if avail ppoint and (bmm.chval = "TXB16") then do:
              if ppoint.name matches "*СП-1*" then v-prefix = "sp_".
              if ppoint.name matches "*СП-2*" then v-prefix = "sp_".
              if ppoint.name matches "*ул. Калдаякова, 30*" then v-prefix = "sp_".
            end.
            */
            v-ofile = "ofile.htm" .
            if lookup(lgr.lgr,"B15,B16,B17,B18,B19,B20") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "fortemaximum.htm".
            end.
            if lookup(lgr.lgr,"B09,B10,B11") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "forteuniversal.htm".
            end.
            if lookup(lgr.lgr,"B01,B02,B03,B04,B05,B06,B07,B08") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "forteprofitable.htm".
            end.
            if lookup(lgr.lgr,"A22,A23,A24") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "metrolux.htm".
            end.
            if lookup(lgr.lgr,"A38,A39,A40") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "fortelux.htm".
            end.
            if lookup(lgr.lgr,"A01,A02,A03,A04,A05,A06") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "standard.htm".
            end.
            if lookup(lgr.lgr,"246") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "gcvpfl.htm".
            end.
            if lookup(lgr.lgr,"478,479,480,481,482,483") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "srochnyi.htm".
            end.
            if lookup(lgr.lgr,"518,519,520") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "nedropol.htm".
            end.
            if lookup(lgr.lgr,"151,153,171,157,176,152,154,172,158,177,173,175,174") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "aaaul.htm".
            end.
            if lookup(lgr.lgr,"202,204,222,208,249") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "aaafl.htm".
            end.
            if lookup(lgr.lgr,"138,139,140") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "aaacfl.htm".
            end.
            if lookup(lgr.lgr,"143,144,145") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "aaacul.htm".
            end.
            output stream v-out to value(v-ofile).
            input from value(v-ifile).
            if caps(cif.type) = "B" and lookup(string(cif.cgr),"403,405,605,610,611") > 0 then do:
               v-ipsvidrus = "свидетельства о государственной регистрации " + cif.ref[8] + " от " + string(cif.expdt,"99.99.9999") + " г.".
               v-ipsvidkz = string(cif.expdt,"99.99.9999") + " жыл&#1171;ы " + cif.ref[8] + " мемлекеттік тіркеу туралы ку&#1241;лік".
               v-binrus = "ИИН".
               v-binkz = "ЖСН".
            end. else do:
               v-ipsvidrus = "Устава".
               v-ipsvidkz = "Жар&#1171;ы".
               v-binrus = "БИН".
               v-binkz = "БСН".
            end.

            repeat:
               import unformatted v-str.
               v-str = trim(v-str).

               run defval(aaa.opnamt, aaa.crc, output v-rval, output v-kval).


               find last acvolt where acvolt.aaa = aaa.aaa no-lock no-error.

               if lookup(lgr.lgr,"478,479,480,481,482,483") > 0  then do:
                  run Sm-vrd(integer(acvolt.x4), output v-acla).
                  run Sm-vrd-kzopti(integer(acvolt.x4), output v-kacla).
                  run defddmm(integer(acvolt.x4), output v-rdd, output v-kdd, output v-rmm, output v-kmm).
                  if acvolt.sts = "d" then do:
                      v-rddmm = v-rdd.
                      v-kddmm = v-kdd.
                  end.
                  else do:
                      v-rddmm = v-rmm.
                      v-kddmm = v-kmm.
                  end.
               end. else do:
                  run Sm-vrd(aaa.cla, output v-acla).
                  run Sm-vrd-kzopti(aaa.cla, output v-kacla).
                  run defddmm(aaa.cla, output v-rdd, output v-kdd, output v-rmm, output v-kmm).
                  v-rddmm = v-rmm.
                  v-kddmm = v-kmm.
               end.



               run Sm-vrd(aaa.opnamt, output v-sumopnam).
               run Sm-vrd-kzopti(aaa.opnamt, output v-ksumopnam).
               run Sm-vrd(lgr.tlimit[1], output v-rnost).
               run Sm-vrd-kzopti(lgr.tlimit[1], output v-knost).

               v-fo = cif.name.
               v-fo = replace (v-fo, " ", ",").
               v-fam =  entry(1,v-fo).
               v-nam = entry(2,v-fo).
               v-otch = entry(3,v-fo).

               repeat:
                 if v-stamp <> "" then do:
                     if v-str matches "*pkstamp*" then do:
                        v-str = replace (v-str, "pkstamp", v-stamp  ).
                        next.
                     end.
                 end.

                 if v-dogsgn <> "" then do:
                     if v-str matches "*pkdogsgn*" then do:
                        v-str = replace (v-str, "pkdogsgn", v-dogsgn  ).
                        next.
                     end.
                 end.

                 if v-str matches "*pustota*" then do:
                    v-str = replace (v-str, "pustota", "&nbsp;&nbsp;" ).
                    next.
                 end.
                 if v-dogsgn = "" then do:
                     if v-str matches "*rcity*" then do:
                        v-str = replace (v-str, "rcity", v-city).
                        next.
                     end.
                     if v-str matches "*kcity*" then do:
                        v-str = replace (v-str, "kcity", v-kcity).
                        next.
                     end.
                 end.
                 if v-dogsgn <> "" then do:
                     if v-str matches "*r1city*" then do:
                        v-str = replace (v-str, "r1city", "").
                        next.
                     end.
                     if v-str matches "*k1city*" then do:
                        v-str = replace (v-str, "k1city", "").
                        next.
                     end.
                 end.

                 if v-str matches "*r1city*" then do:
                    v-str = replace (v-str, "r1city", "Филиала в г. " + v-city).
                    next.
                 end.
                 if v-str matches "*k1city*" then do:
                    v-str = replace (v-str, "k1city", v-kcity + " &#1179;аласында&#1171;ы Филиал ").
                    next.
                 end.

                 if v-str matches "*kmes*" then do:
                    v-str = replace (v-str, "kmes", vk-mes ).
                    next.
                 end.

                 if v-str matches "*rmes*" then do:
                    v-str = replace (v-str, "rmes", vr-mes ).
                    next.
                 end.

                 if v-str matches "*rchs*" then do:
                    v-str = replace (v-str, "rchs", string(day(g-today),"99") ).
                    next.
                 end.

                 if v-str matches "*yyyy*" then do:
                    v-str = replace (v-str, "yyyy", string(year(g-today)) ).
                    next.
                 end.

                 find first codfr where codfr.codfr = "DKOSNKZ" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*kdover*" then do:
                        v-str = replace (v-str, "kdover", codfr.name[1] ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*kdover*" then do:
                        v-str = replace (v-str, "kdover", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.

                 find first codfr where codfr.codfr = "DKOSN" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*rdover*" then do:
                        v-str = replace (v-str, "rdover",  codfr.name[1] ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*rdover*" then do:
                        v-str = replace (v-str, "rdover", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.


                 find first codfr where codfr.codfr = "DKKOGOKZ" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*kdolzhni*" then do:
                        v-str = replace (v-str, "kdolzhni", ENTRY(1,codfr.name[1],",")).
                        next.
                     end.
                 end. else do:
                         if v-str matches "*kdolzhni*" then do:
                            v-str = replace (v-str, "kdolzhni", "&nbsp;&nbsp;" ).
                            next.
                         end.
                 end.
                 find first codfr where codfr.codfr = "DKKOGO" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*rdolzhnr*" then do:
                        v-str = replace (v-str, "rdolzhnr", ENTRY(1,codfr.name[1],",")).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*rdolzhnr*" then do:
                        v-str = replace (v-str, "rdolzhnr", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.


                 find first codfr where codfr.codfr = "DKKOGOKZ" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*kfilchifi*" then do:
                        v-str = replace (v-str, "kfilchifi", ENTRY(2,codfr.name[1],",")).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*kfilchifi*" then do:
                        v-str = replace (v-str, "kfilchifi", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.
                 find first codfr where codfr.codfr = "DKKOGO" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*rfilchifr*" then do:
                        v-str = replace (v-str, "rfilchifr", ENTRY(2,codfr.name[1],",")).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*rfilchifr*" then do:
                        v-str = replace (v-str, "rfilchifr", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.

                 find first codfr where codfr.codfr = "DKDOLZHN" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*rdolzhn*" then do:
                        v-str = replace (v-str, "rdolzhn",codfr.name[1]).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*rdolzhn*" then do:
                        v-str = replace (v-str, "rdolzhn", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.

                 find first codfr where codfr.codfr = "DKPODP" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*rfiochif*" then do:
                        v-str = replace (v-str, "rfiochif",codfr.name[1]).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*rfiochif*" then do:
                        v-str = replace (v-str, "rfiochif", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.


                 find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif
                     and sub-cod.d-cod = "clnchf" no-lock no-error.
                 if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
                    v-tmpstr = "&nbsp;&nbsp;".
                    if v-str matches "*clnchif*" then do:
                        v-str = replace (v-str, "clnchif", v-tmpstr ).
                        next.
                    end.
                 end.
                 else do:
                     v-tmpstr = trim(sub-cod.rcode).
                     if v-str matches "*clnchif*" then do:
                        v-str = replace (v-str, "clnchif", v-tmpstr).
                        next.
                     end.
                 end.

                 find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif
                     and sub-cod.d-cod = "clnchf" no-lock no-error.
                 if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
                    v-tmpstr = "&nbsp;&nbsp;".
                    if v-str matches "*sclnchf*" then do:
                        v-str = replace (v-str, "sclnchf", v-tmpstr ).
                        next.
                    end.
                 end.
                 else do:
                     v-tmpstr = trim(sub-cod.rcode).
                     v-tmpstr1 = v-tmpstr.
                     v-tmpstr1 = entry(1,v-tmpstr," ") + " " + SUBSTRING(entry(2,v-tmpstr," "),1,1) + "." + " " + SUBSTRING(entry(3,v-tmpstr," "),1,1) + "." no-error.
                     if v-str matches "*sclnchf*" then do:
                        v-str = replace (v-str, "sclnchf", v-tmpstr1 ).
                        next.
                     end.
                 end.

                 if caps(cif.type) = "B" and lookup(string(cif.cgr),"403,405,605,610,611") > 0 then do:
                     if v-str matches "*rclndlzh*" then do:
                        v-str = replace (v-str, "rclndlzh", cif.prefix ).
                        next.
                     end.
                 end.

                 v-tmpstr = "".
                 find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif
                     and sub-cod.d-cod = "clnchfd1" no-lock no-error.
                 if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
                     if v-str matches "*rclndlzh*" then do:
                        v-str = replace (v-str, "rclndlzh", v-tmpstr ).
                        next.
                     end.
                     if v-str matches "*rclnchfdlzh*" then do:
                        v-str = replace (v-str, "rclnchfdlzh", v-tmpstr ).
                        next.
                     end.
                     if v-str matches "*kclnchfdlzh*" then do:
                        v-str = replace (v-str, "kclnchfdlzh", v-tmpstr ).
                        next.
                     end.
                 end.
                 else do:
                     v-tmpstr = trim(sub-cod.rcode).
                     if v-str matches "*rclndlzh*" then do:
                        v-str = replace (v-str, "rclndlzh", v-tmpstr ).
                        next.
                     end.
                     v-tmpstr1 = v-tmpstr.
                     if TRIM(CAPS(v-tmpstr)) = "ДИРЕКТОР" then do: v-tmpstr = "Директора". v-tmpstr1 = "Директоры". end.
                     if TRIM(CAPS(v-tmpstr)) = "ГЛАВА КХ" then do: v-tmpstr = "Главы КХ". v-tmpstr1 = "Ш&#1178; басшысы". end.
                     if TRIM(CAPS(v-tmpstr)) = "ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ" then do: v-tmpstr = "Индивидуального предпринимателя". v-tmpstr1 = "Жеке к&#1241;сіпкер". end.
                     if caps(cif.type) = "B" and lookup(string(cif.cgr),"403,405,605,610,611") > 0 then do: v-tmpstr = "". v-tmpstr1 = "". end.

                     if v-str matches "*rclnchfdlzh*" then do:
                        v-str = replace (v-str, "rclnchfdlzh", trim(v-tmpstr) ).
                        next.
                     end.
                     if v-str matches "*kclnchfdlzh*" then do:
                        v-str = replace (v-str, "kclnchfdlzh", trim(v-tmpstr1) ).
                        next.
                     end.
                 end.

                 if v-str matches "*rbin*" then do:
                    v-str = replace (v-str, "rbin", v-binrus ).
                    next.
                 end.
                 if v-str matches "*kbin*" then do:
                    v-str = replace (v-str, "kbin", v-binkz ).
                    next.
                 end.


                 if v-str matches "*rustav*" then do:
                    v-str = replace (v-str, "rustav", v-ipsvidrus ).
                    next.
                 end.
                 if v-str matches "*kustav*" then do:
                    v-str = replace (v-str, "kustav", v-ipsvidkz ).
                    next.
                 end.

                 if v-str matches "*namecompany*" then do:
                    v-str = replace (v-str, "namecompany",  trim(cif.name)).
                    next.
                 end.

                 if v-str matches "*rfsobs*" then do:
                    v-str = replace (v-str, "rfsobs", cif.prefix ).
                    next.
                 end.
                 v-tmpstr = cif.prefix.
                 if trim(cif.prefix) = "ГУ" then v-tmpstr = "ММ".
                 if trim(cif.prefix) = "Учреждение" then v-tmpstr = "Мекеме".
                 if trim(cif.prefix) = "ПК" then v-tmpstr = "&#1256;К". /*в сокращении повтор :( */
                 if trim(cif.prefix) = "АО" then v-tmpstr = "А&#1178;".
                 if trim(cif.prefix) = "ТДО" then v-tmpstr = "&#1178;ЖС".
                 if trim(cif.prefix) = "ТОО" then v-tmpstr = "ЖШС".
                 if trim(cif.prefix) = "КД" then v-tmpstr = "КС".
                 if trim(cif.prefix) = "ПТ" then v-tmpstr = "ТС".
                 if trim(cif.prefix) = "РО" then v-tmpstr = "ДБ".
                 if trim(cif.prefix) = "ОФ" then v-tmpstr = "&#1178;&#1178;".
                 if trim(cif.prefix) = "ПК" then v-tmpstr = "ТК". /*в сокращении повтор :( */
                 if trim(cif.prefix) = "АО" then v-tmpstr = "А&#1178;".
                 if trim(cif.prefix) = "ОО" then v-tmpstr = "&#1178;Б".
                 if trim(cif.prefix) = "ГП" then v-tmpstr = "МК".
                 if trim(cif.prefix) = "ОТ" then v-tmpstr = "КС".
                 if trim(cif.prefix) = "ИП" then v-tmpstr = "ЖК".
                 if lookup(trim(cif.prefix),"КХ,К/Х,К/х") > 0 then v-tmpstr = "Ш&#1178;".
                 if lookup(trim(cif.prefix),"Частный нотариус,ЧН") > 0 then v-tmpstr = "ЖН".
                 if trim(cif.prefix) = "ЧП" then v-tmpstr = "ЖК".
                 if trim(cif.prefix) = "НОТАРИУС" then v-tmpstr = "НОТАРИУС".
                 if lookup(trim(cif.prefix),"Частное учреждение,ЧУ") > 0 then v-tmpstr = "ЖМ".
                 if trim(cif.prefix) = "ЗАО" then v-tmpstr = "ЖА&#1178;".

                 if trim(cif.prefix) = "Посольство" then v-tmpstr = "Елшілік".
                 if trim(cif.prefix) = "ОАО" then v-tmpstr = "АА&#1178;".
                 if trim(cif.prefix) = "БПГ" then v-tmpstr = "МБ&#1178;".
                 if trim(cif.prefix) = "ПС" then v-tmpstr = "&#1256;БК".
                 if trim(cif.prefix) = "КТ" then v-tmpstr = "КС".
                 if trim(cif.prefix) = "НАО" then v-tmpstr = "КА&#1178;".
                 if trim(cif.prefix) = "Представительство" then v-tmpstr = "&#1256;кілдік".
                 if trim(cif.prefix) = "ДКУ" then v-tmpstr = "БНМ".
                 if trim(cif.prefix) = "СП" then v-tmpstr = "БК".
                 if trim(cif.prefix) = "ОФ" then v-tmpstr = "ОФ".
                 if trim(cif.prefix) = "ТДО" then v-tmpstr = "&#1178;ЖС".
                 if trim(cif.prefix) = "НП" then v-tmpstr = "НП".
                 if trim(cif.prefix) = "СПК" then v-tmpstr = "АТК".
                 if trim(cif.prefix) = "КА" then v-tmpstr = "АК".
                 if trim(cif.prefix) = "КСК" then v-tmpstr = "ЖПК".
                 if trim(cif.prefix) = "КСП" then v-tmpstr = "ЖЖК".
                 if trim(cif.prefix) = "ЖК" then v-tmpstr = "ТК".
                 if trim(cif.prefix) = "ЖСК" then v-tmpstr = "Т&#1178;К".
                 if trim(cif.prefix) = "Ассоциация" then v-tmpstr = "Ассоциация".
                 if trim(cif.prefix) = "Компания" then v-tmpstr = "Компаниясы".
                 if trim(cif.prefix) = "КОМПАНИЯ" then v-tmpstr = "КОМПАНИЯСЫ".

                 if v-str matches "*kfsobs*" then do:
                    v-str = replace (v-str, "kfsobs", v-tmpstr ).
                    next.
                 end.

                 if v-str matches "*familia*" then do:
                    v-str = replace (v-str, "familia", v-fam ).
                    next.
                 end.
                 if v-str matches "*nameofclient*" then do:
                    v-str = replace (v-str, "nameofclient", v-nam ).
                    next.
                 end.
                 if v-nam <> "" then do:
                     if v-str matches "*snameofcln*" then do:
                        v-str = replace (v-str, "snameofcln", SUBSTRING(v-nam,1,1) + ".").
                        next.
                     end.
                 end. else do:
                     if v-str matches "*snameofcln*" then do:
                        v-str = replace (v-str, "snameofcln", " ").
                        next.
                     end.
                 end.

                 if v-str matches "*othestvoclienta*" then do:
                    v-str = replace (v-str, "othestvoclienta", v-otch ).
                    next.
                 end.

                 if v-otch <> "" then do:
                     if v-str matches "*sothestvocln*" then do:
                        v-str = replace (v-str, "sothestvocln", SUBSTRING(v-otch,1,1) + "." ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*sothestvocln*" then do:
                        v-str = replace (v-str, "sothestvocln", " " ).
                        next.
                     end.
                 end.

                 if v-str matches "*wjfnfkrfrj*" then do:
                    v-str = replace (v-str, "wjfnfkrfrj", string(aaa.opnamt) + " (" + v-sumopnam + ")").
                    next.
                 end.

                 if v-str matches "*kvclsm*" then do:
                    v-str = replace (v-str, "kvclsm", string(aaa.opnamt) + " (" + v-ksumopnam + ")").
                    next.
                 end.

                 if v-str matches "*kvaluta*" then do:
                    v-str = replace (v-str, "kvaluta", v-kval) .
                    next.
                 end.

                 if v-str matches "*rvaluta*" then do:
                    v-str = replace (v-str, "rvaluta", v-rval) .
                    next.
                 end.

                 if v-str matches "*valutavklada*" then do:
                    v-str = replace (v-str, "valutavklada", crc.des) .
                    next.
                 end.


                 if lookup(lgr.lgr,"478,479,480,481,482,483") > 0  then do:
                     if v-str matches "*kolvomes*" then do:
                        v-str = replace (v-str, "kolvomes", string(integer(acvolt.x4)) + " (" + v-acla + ") " + v-rddmm + " "  ).
                        next.
                     end.
                     if v-str matches "*kklasvka*" then do:
                        v-str = replace (v-str, "kklasvka", string(integer(acvolt.x4)) + " (" + v-kacla + ") " + v-kddmm + " "  ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*kolvomes*" then do:
                        v-str = replace (v-str, "kolvomes", string(aaa.cla) + " (" + v-acla + ") " + v-rddmm + " " ).
                        next.
                     end.
                     if v-str matches "*kklasvka*" then do:
                        v-str = replace (v-str, "kklasvka", string(aaa.cla) + " (" + v-kacla + ") " + v-kddmm + " "  ).
                        next.
                     end.
                 end.


                 if v-str matches "*rclaperiod*" then do:
                    v-str = replace (v-str, "rclaperiod", vr-period).
                    next.
                 end.
                 if v-str matches "*kclaperiod*" then do:
                    v-str = replace (v-str, "kclaperiod", vk-period).
                    next.
                 end.


                 if v-str matches "*iikclienta*" then do:
                    v-str = replace (v-str, "iikclienta", /*aaa.aaa*/ buf-aaa1.aaa ).
                    next.
                 end.

                 if v-str matches "*dstavka*" then do:
                   v-str = replace (v-str, "dstavka", string(aaa.rate,">9.99") ).
                   next.
                 end.
                 if v-str matches "*efstavka*" then do:
                   v-str = replace (v-str, "efstavka", string(ROUND(decimal(acvolt.x2),1),">9.9")).
                   next.
                 end.

                 if v-str matches "*knost*" then do:
                    v-str = replace (v-str, "knost", string(lgr.tlimit[1]) + " (" + v-knost + ")").
                    next.
                 end.
                 if v-str matches "*rnost*" then do:
                    v-str = replace (v-str, "rnost", string(lgr.tlimit[1]) + " (" + v-rnost + ")").
                    next.
                 end.

                 if v-str matches "*$code$*" then do:
                    v-str = replace (v-str, "$code$", cif.attn ).
                    next.
                 end.
                 if v-str matches "*$cword$*" then do:
                    find first pcstaff0 where pcstaff0.cif = cif.cif and pcstaff0.aaa = aaa.aaa no-lock no-error.
                    if avail pcstaff0 then v-str = replace (v-str, "$cword$", pcstaff0.cword ).
                    else v-str = replace (v-str, "$cword$", " " ).
                    next.
                 end.

                 if aaa.crc = 1 then do:
                    v-tmpstr = "в Тенге".
                    v-tmpstr1 = "Те&#1226;геде".
                 end.
                 if aaa.crc = 2 then do:
                    v-tmpstr = "в Долларах США".
                    v-tmpstr1 = "А&#1178;Ш долларында".
                 end.
                 if aaa.crc = 3 then do:
                    v-tmpstr = "в Евро".
                    v-tmpstr1 = "Еурода".
                 end.
                 if aaa.crc = 4 then do:
                    v-tmpstr = "в Российских рублях".
                    v-tmpstr1 = "Ресей рублiнде".
                 end.
                 if aaa.crc = 6 then do:
                    v-tmpstr = "в Фунтах стерлингах".
                    v-tmpstr1 = "Фунт стерлингте".
                 end.
                 if aaa.crc = 7 then do:
                    v-tmpstr = "В Шведских кронах".
                    v-tmpstr1 = "Шведтік кронда".
                 end.
                 if aaa.crc = 8 then do:
                    v-tmpstr = "В Австралийских долларах".
                    v-tmpstr1 = "Австралиялы&#1179; долларда".
                 end.
                 if aaa.crc = 9 then do:
                    v-tmpstr = "В Швейцарских франках".
                    v-tmpstr1 = "Швейцариялы&#1179; франкте".
                 end.

                 if v-str matches "*rvalr*" then do:
                    v-str = replace (v-str, "rvalr", v-tmpstr ).
                    next.
                 end.
                 if v-str matches "*kvalk*" then do:
                    v-str = replace (v-str, "kvalk", v-tmpstr1 ).
                    next.
                 end.
                 v-tmpstrlist = "".
                 v-tmpstrlist1 = "".
                 do i =  1 to NUM-ENTRIES(v-acclist):
                    if v-tmpstrlist <> "" then v-tmpstrlist = v-tmpstrlist + " <br> ".
                    if v-tmpstrlist1 <> "" then v-tmpstrlist1 = v-tmpstrlist1 + " <br> ".

                    find first buf-aaa where buf-aaa.aaa = ENTRY(i,v-acclist) no-lock no-error.
                    if buf-aaa.crc = 1 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Тенге, номер Счета (ИИК):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 2 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Долларах США, номер Счета (ИИК):&nbsp;&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 3 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Евро, номер Счёта (ИИК):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 4 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Российских рублях, номер Счета (ИИК):&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 6 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Фунтах стерлингах, номер Счета (ИИК):&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 7 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Шведских кронах, номер Счета (ИИК):&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 8 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Австралийских долларах, номер Счета (ИИК):&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 9 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Швейцарских франках, номер Счета (ИИК):&nbsp;" + buf-aaa.aaa.

                    if buf-aaa.crc = 1 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Те&#1226;геде, Шот н&#1257;мірі (ЖСК):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 2 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;А&#1178;Ш долларында, Шот н&#1257;мірі (ЖСК):&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 3 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Еурода, Шот н&#1257;мірі (ЖСК):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 4 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Ресей рублінде, Шот н&#1257;мірі (ЖСК):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 6 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Фунт стерлингте , Шот н&#1257;мірі (ЖСК):&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 7 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Шведтік кронда , Шот н&#1257;мірі (ЖСК):&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 8 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Австралиялы&#1179; долларда , Шот н&#1257;мірі (ЖСК):&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 9 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Швейцариялы&#1179; франкте , Шот н&#1257;мірі (ЖСК):&nbsp;" + buf-aaa.aaa.
                 end.
                 if v-str matches "*raaalist*" then do:
                    v-str = replace (v-str, "raaalist", v-tmpstrlist ).
                    next.
                 end.
                 if v-str matches "*kaaalist*" then do:
                    v-str = replace (v-str, "kaaalist", v-tmpstrlist1 ).
                    next.
                 end.

                 v-tmpstr = cif.addr[1].
                 v-tmpstr = replace (v-tmpstr, ",", ", " ).
                 if v-str matches "*adresclienta*" then do:
                    v-str = replace (v-str, "adresclienta", v-tmpstr ).
                    next.
                 end.

                 if v-str matches "*telclienta*" then do:
                    v-str = replace (v-str, "telclienta", cif.tel ).
                    next.
                 end.

                 if v-str matches "*rnnclienta*" then do:
                    v-str = replace (v-str, "rnnclienta", cif.jss ).
                    next.
                 end.

                 if v-str matches "*iincln*" then do:
                    v-str = replace (v-str, "iincln", cif.bin ).
                    next.
                 end.

                 if NUM-ENTRIES(cif.pss, " ") > 0 then do:
                     if v-str matches "*udosn*" then do:
                        v-str = replace (v-str, "udosn", ENTRY(1,cif.pss," ") ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*udosn*" then do:
                        v-str = replace (v-str, "udosn", "&nbsp;" ).
                        next.
                     end.
                 end.

                 if NUM-ENTRIES(cif.pss, " ") > 3 then do:
                     if v-str matches "*rkemvid*" then do:
                        v-str = replace (v-str, "rkemvid", ENTRY(3,cif.pss," ") ).
                        next.
                     end.
                     if v-str matches "*kkemvid*" then do:
                        v-tmpstr =  ENTRY(3,cif.pss," ").
                        if  TRIM(CAPS(v-tmpstr)) = "МВД" then v-str = replace (v-str, "kkemvid", "IIM" ). else
                            if  TRIM(CAPS(v-tmpstr)) = "МЮ" then v-str = replace (v-str, "kkemvid", "&#1240;М" ). else
                                v-str = replace (v-str, "kkemvid", v-tmpstr ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*rkemvid*" then do:
                        v-str = replace (v-str, "rkemvid", "&nbsp;" ).
                        next.
                     end.
                     if v-str matches "*kkemvid*" then do:
                        v-str = replace (v-str, "kkemvid", "&nbsp;" ).
                        next.
                     end.
                 end.

                 if NUM-ENTRIES(cif.pss, " ") > 1 then do:
                     if v-str matches "*dtvid*" then do:
                        v-tmpstr = ENTRY(2,cif.pss," ").
                        if length(v-tmpstr) > 8 then do:
                           v-tmpstr = replace (v-tmpstr, "/", "." ).
                        end.
                        if length(v-tmpstr) = 8 then do:
                           v-tmpstr = SUBSTRING (v-tmpstr, 1, 2) + "." + SUBSTRING (v-tmpstr, 3, 2) + "." + SUBSTRING (v-tmpstr, 5, 4).
                        end.
                        v-str = replace (v-str, "dtvid", v-tmpstr ).
                     end.
                 end. else do:
                     if v-str matches "*dtvid*" then do:
                        v-str = replace (v-str, "dtvid", "&nbsp;" ).
                        next.
                     end.
                 end.

                 find ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock no-error.
                 if avail ppoint and ppoint.name matches "*СП*" and ppoint.info[5] <> "" and ppoint.info[6] <> "" and ppoint.info[7] <> "" and aaa.sta <> "C" then do:

                    if v-str matches "*rcity*" then do:
                       v-str = replace (v-str, "rcity", ENTRY(2,ENTRY(1,trim(ppoint.info[5])),".") ).
                       next.
                    end.
                    if v-str matches "*kcity*" then do:
                       v-str = replace (v-str, "kcity", ENTRY(1,ENTRY(1,trim(ppoint.info[6]))," ") ).
                       next.
                    end.

                    if v-str matches "*raddrbank*" then do:
                       v-str = replace (v-str, "raddrbank", trim(ppoint.info[5]) ).
                       next.
                    end.
                    if v-str matches "*telbank*" then do:
                       v-str = replace (v-str, "telbank", trim(ppoint.info[7]) ).
                       next.
                    end.
                    if v-str matches "*kaddrbank*" then do:
                       v-str = replace (v-str, "kaddrbank", trim(ppoint.info[6]) ).
                       next.
                    end.
                 end.


                 find first cmp no-lock no-error.
                 if avail cmp then do:
                     if v-str matches "*raddrbank*" then do:
                        v-str = replace (v-str, "raddrbank", cmp.addr[1] ).
                        next.
                     end.
                     if v-str matches "*telbank*" then do:
                        v-str = replace (v-str, "telbank", cmp.tel ).
                        next.
                     end.
                     if v-str matches "*rnnbank*" then do:
                        v-str = replace (v-str, "rnnbank", cmp.addr[2] ).
                        next.
                     end.

                 end.
                 v-kazaddr = "".
                 find sysc where sysc.sysc = "bnkadr" no-lock no-error.
                 if avail sysc then do:
                   v-kazaddr = entry(11, sysc.chval, "|") no-error.
                 end.
                 if v-kazaddr <> "" then do:
                     if v-str matches "*kaddrbank*" then do:
                        v-str = replace (v-str, "kaddrbank", v-kazaddr ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*kaddrbank*" then do:
                        v-str = replace (v-str, "kaddrbank", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.
                if v-str matches "*bicbank*" then do:
                    v-str = replace (v-str, "bicbank", v-clecod ).
                    next.
                 end.
                 if v-str matches "*namebankDgv*" then do:
                    v-str = replace (v-str, "namebankDgv", v-nbankDgv ).
                    next.
                 end.
                 if v-str matches "*namebankfil*" then do:
                    v-str = replace (v-str, "namebankfil", v-nbankfil ).
                    next.
                 end.
                 find sysc where sysc.sysc = "bnkbin" no-lock no-error.
                 if avail sysc then do:
                     if v-str matches "*binbank*" then do:
                        v-str = replace (v-str, "binbank", sysc.chval ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*binbank*" then do:
                        v-str = replace (v-str, "binbank", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.


                 if v-str matches "*filialnameru*" then do:
                    v-str = replace (v-str, "filialnameru", cmp.name ) no-error.
                    next.
                 end.

                 find sysc where sysc.sysc = "bnkadr" no-lock no-error.
                 if v-str matches "*filialnamekz*" then do:
                    v-str = replace (v-str, "filialnamekz", entry(14, sysc.chval, "|") ) no-error.
                    next.
                 end.


                 leave.
               end.
             put stream v-out unformatted v-str skip.
            end.


            input close.
            output stream v-out close.
            unix silent cptunkoi value(v-ofile) winword.
        end. /*lookup(lgr.lgr,"A22,A23,A24") > 0 */

        if (v-ans = false) and (lookup(lgr.lgr,"B15,B16,B17,B18,B19,B20,B09,B10,B11,B01,B02,B03,B04,B05,B06,B07,B08,A38,A39,A40,A22,A23,A24,A01,A02,A03,A04,A05,A06,246,478,479,480,481,482,483,518,519,520,151,153,171,157,176,152,154,172,158,177,173,175,174,202,204,222,208,249,138,139,140,146,144,145") = 0) then do:

          do:
            if lookup(string(lgr.feensf),"1,2,3,4,5,6,7") <> 0 /*or  (lgr.feensf = 3 and lgr.des begins "Метро-ЛЮКС")*/ then do:
            find cif where cif.cif = s-cif no-lock.
            /*Первая часть для всех договоров*/
             v-ofile = "ofile.htm" .

             if bmm.chval = "TXB00" then
                v-ifile = "/data/export/docum.htm".
             else
                v-ifile = "/data/export/op_docum.htm".

             /*Метрошка*/
             if lgr.feensf = 7 then do:
                if bmm.chval = "TXB00" then
                   v-ifile = "/data/export/metroshka1.htm".
                else
                   v-ifile = "/data/export/op_metroshka1.htm".
             end.



             /*Первая часть договоров*/
                output stream v-out to value(v-ofile).
                input from value(v-ifile).
                   repeat:
                      import unformatted v-str.
                      v-str = trim(v-str).

                      repeat:
                        if v-str matches "*rchs*" then do:
                           v-str = replace (v-str, "rchs", string(day(g-today)) ).
                           next.
                        end.
                        if v-str matches "*kmes*" then do:
                           v-str = replace (v-str, "kmes", vk-mes ).
                           next.
                        end.
                        if v-str matches "*rcity*" then do:
                           v-str = replace (v-str, "rcity", v-city).
                           next.
                        end.
                        if v-str matches "*rmes*" then do:

                           v-str = replace (v-str, "rmes", vr-mes ).
                           next.
                        end.
                        if v-str matches "*dirdeprt*" then do:
                           v-str = replace (v-str, "dirdeprt", string(v-podp) ).
                           next.
                        end.
                        leave.
                      end.
                    put stream v-out unformatted v-str skip.
                   end.
                input close.
                output stream v-out close.
                unix silent cptunkoi value(v-ofile) winword.

               /*вторая часть договоров*/
                 if aaa.crc = 1 then v-rastr = "10".
                 if aaa.crc = 2 then v-rastr = "5".
                 if aaa.crc = 3 then v-rastr = "4".

                  run Sm-vrd(aaa.cla, output v-acla).
                  run Sm-vrd-kzopti(aaa.cla, output v-kacla).
                  run Sm-vrd(aaa.opnamt, output v-sumopnam).
                  run Sm-vrd-kzopti(aaa.opnamt, output v-ksumopnam).
                  find last acvolt where acvolt.aaa = aaa.aaa no-lock no-error.
                /*  v-sumopnam = string(aaa.opnamt) + " (" + v-sumopnam + ")"  . */
                  v-fo = cif.name.
                  v-fo = replace (v-fo, " ", ",").
                  v-fam =  entry(1,v-fo).
                  v-nam = entry(2,v-fo).
                  v-otch = entry(3,v-fo).

                if bmm.chval = "TXB00" then do:
                   if lgr.feensf =  1 then do:    v-ifile = "/data/export/standart.htm".  end.
                   if lgr.feensf =  2 then do:    v-ifile = "/data/export/classic.htm".  end.
                   if lgr.feensf =  3 then do:    v-ifile = "/data/export/luks.htm".  end.
                   if lgr.feensf =  6 then do:    v-ifile = "/data/export/luks.htm".  end.
                   if lgr.feensf =  4 then do:    v-ifile = "/data/export/vip.htm".  end.
                   if lgr.feensf =  5 then do:    v-ifile = "/data/export/superluks.htm".  end.
                end.
                else
                do:
                   if lgr.feensf =  1 then do:    v-ifile = "/data/export/op_standart.htm".  end.
                   if lgr.feensf =  2 then do:    v-ifile = "/data/export/op_classic.htm".  end.
                   if lgr.feensf =  3 then do:    v-ifile = "/data/export/op_luks.htm".  end.
                   if lgr.feensf =  6 then do:    v-ifile = "/data/export/op_luks.htm".  end.
                   if lgr.feensf =  4 then do:    v-ifile = "/data/export/op_vip.htm".  end.
                   if lgr.feensf =  5 then do:    v-ifile = "/data/export/op_superluks.htm".  end.
                end.
                /*Метрошка*/
                if lgr.feensf = 7 then do:
                    if bmm.chval = "TXB00" then do:
                       v-ifile = "/data/export/mtroshka2.htm".
                    end.
                    else do:
                       v-ifile = "/data/export/op_mtroshka2.htm".
                    end.
                end.

                /*Пенсионный*/
                if lgr.feensf = 3 and  not lgr.des   begins "Метро-ЛЮКС" then do:
                    if bmm.chval = "TXB00" then do:
                       v-ifile = "/data/export/pensionii.htm".
                    end.
                    else do:
                       v-ifile = "/data/export/op_pensionii.htm".
                    end.
                end.
              v-ofile = "part2.htm" .
              output stream v-out to value(v-ofile).
              input from value(v-ifile).
                 repeat:
                    import unformatted v-str.
                    v-str = trim(v-str).
                    repeat:
                      if v-str matches "*perrsent*" then do:
                         v-str = replace (v-str, "perrsent", v-rastr ).
                         next.
                      end.
                      if v-str matches "*familia*" then do:
                         v-str = replace (v-str, "familia", v-fam ).
                         next.
                      end.
                      if v-str matches "*nameofclient*" then do:
                         v-str = replace (v-str, "nameofclient", v-nam ).
                         next.
                      end.
                      if v-str matches "*othestvoclienta*" then do:
                         v-str = replace (v-str, "othestvoclienta", v-otch ).
                         next.
                      end.
                      if v-str matches "*rnnclienta*" then do:
                         v-str = replace (v-str, "rnnclienta", cif.jss ).
                         next.
                      end.

                      if v-str matches "*adresclienta*" then do:
                         v-str = replace (v-str, "adresclienta", cif.addr[1] + ' ' + cif.addr[2] ).
                         next.
                      end.
                      if v-str matches "*yelclienta*" then do:
                         v-str = replace (v-str, "yelclienta", cif.tel ).
                         next.
                      end.
                      if v-str matches "*iikclienta*" then do:
                         v-str = replace (v-str, "iikclienta", aaa.aaa ).
                         next.
                      end.
                      if v-str matches "*wjfnfkrfrj*" then do:
                         v-str = replace (v-str, "wjfnfkrfrj", string(aaa.opnamt) + " (" + v-sumopnam + ")").
                         next.
                      end.

                      if v-str matches "*kvclsm*" then do:
                         v-str = replace (v-str, "kvclsm", string(aaa.opnamt) + " (" + v-ksumopnam + ")").
                         next.
                      end.

                      if v-str matches "*valutavklada*" then do:
                         v-str = replace (v-str, "valutavklada", crc.des) .
                         next.
                      end.
                      if v-str matches "*datav1*" then do:
                         v-str = replace (v-str, "datav1", string(aaa.regdt)) .
                         next.
                      end.
                      if v-str matches "*datav2*" then do:
                         v-str = replace (v-str, "datav2", string(aaa.expdt) ).
                         next.
                      end.

                      if v-str matches "*kolvomes*" then do:
                         v-str = replace (v-str, "kolvomes", string(aaa.cla) + " (" + v-acla + ")"  ).
                         next.
                      end.
                      if v-str matches "*kklasvka*" then do:
                         v-str = replace (v-str, "kklasvka", string(aaa.cla) + " (" + v-kacla + ")"  ).
                         next.
                      end.
                      if v-str matches "*kmeskl*" then do:
                         v-str = replace (v-str, "kmeskl", string(aaa.cla) + " ()"  ).
                         next.
                      end.
                      if v-str matches "*dirdeprt*" then do:
                         v-str = replace (v-str, "dirdeprt", string(v-podp) ).
                         next.
                      end.
                      if v-str matches "*lukstavka*" then do:
                         v-str = replace (v-str, "lukstavka", string("10") ).
                         next.
                      end.

                      /*Данные филиала*/
                       if v-str matches "*danniefil*" then do:
                          v-str = replace (v-str, "danniefil", v-bickfiliala).
                          next.
                       end.
                       if v-str matches "*bickfilialakz*" then do:
                          v-str = replace (v-str, "bickfilialakz", v-bickfilialakz).
                          next.
                       end.
                       if v-str matches "*dstavka*" then do:
                         v-str = replace (v-str, "dstavka", string(aaa.rate) ).
                         next.
                       end.
                       if v-str matches "*efstavka*" then do:
                         v-str = replace (v-str, "efstavka", acvolt.x2).
                         next.
                       end.
                       leave.
                    end.
                    put stream v-out unformatted v-str skip.
                 end.
              input close.
              output stream v-out close.
              unix silent cptunkoi value(v-ofile) winword.
               message  "  ВНИМАНИЕ! "
               skip(5) "   ПРОВЕРЬТЕ ТЕКСТ ДОГОВОРА!  "
               skip "      При обнаружении ошибок сообщите в ДИТ.    "
               skip(5)  view-as alert-box question buttons ok title "" .

           end.
      end.
      find sysc where sysc.sysc = 'VC-AGR' no-lock no-error.
      v-sys = sysc.chval.
      if avail sysc then
         if lookup (lgr.lgr, sysc.chval) <> 0 or   lookup (lgr.lgr, "247,248") <> 0   then do:
             find cif where cif.cif = s-cif no-lock.
             v-ofile = "contract.htm".
             if lgr.tlev = 2 then do: /* физ лицо */
             if bmm.chval = "TXB00" then do:
                 if lgr.lgr = "247" or lgr.lgr = "248" then
                    v-ifile = "/data/export/kassanovaof.htm".
                 else
                    v-ifile = "/data/export/teksof.htm".
             end.
             else
             do:
                 if lgr.lgr = "247" or lgr.lgr = "248" then
                     v-ifile = "/data/export/kassanovafil.htm".
                 else
                     v-ifile = "/data/export/teksfil.htm".
             end.
              output stream v-out to value(v-ofile).
              input from value(v-ifile).
              repeat:
                    import unformatted v-str.
                    v-str = trim(v-str).
                    repeat:
                        if v-str matches "*citiiii*" then do:
                           v-str = replace (v-str, "citiiii", v-city).
                           next.
                        end.
                        if v-str matches "*shsl*" then do:
                           v-str = replace (v-str, "shsl", string(day(g-today)) ).
                           next.
                        end.

                        if v-str matches "*rvyears*" then do:
                           v-str = replace (v-str, "rvyears", string(year(g-today)) ).
                           next.
                        end.


                        if v-str matches "*msmsms*" then do:
                           v-str = replace (v-str, "msmsms", string(vr-mes) ).
                           next.
                        end.

                        if v-str matches "*mskzmskzms*" then do:
                           v-str = replace (v-str, "mskzmskzms", string(vk-mes)).
                           next.
                        end.
                        if v-str matches "*fioclienta*" then do:
                           v-str = replace (v-str, "fioclienta", string(cif.name) ).
                           next.
                        end.
                        if v-str matches "*iikname*" then do:
                           v-str = replace (v-str, "iikname", string(aaa.aaa)).
                           next.
                        end.
                        if v-str matches "*valutasheta*" then do:
                           v-str = replace (v-str, "valutasheta", string(crc.des) ).
                           next.
                        end.
                        if v-str matches "*datav1*" then do:
                           v-str = replace (v-str, "datav1", string(aaa.regdt) ).
                           next.
                        end.
                        if v-str matches "*dirdeprt*" then do:
                           v-str = replace (v-str, "dirdeprt", string(v-podp) ).
                           next.
                        end.
                        if v-str matches "*adresclienta*" then do:

                           v-str = replace (v-str, "adresclienta", cif.addr[1] ).
                           next.
                        end.
                        if v-str matches "*passportclienta*" then do:
                           v-str = replace (v-str, "passportclienta", string(cif.pss) ).
                           next.
                        end.
                        if v-str matches "*telclienta*" then do:
                           v-str = replace (v-str, "telclienta", cif.tel ).
                           next.
                        end.
                        if v-str matches "*faxclienta*" then do:
                           v-str = replace (v-str, "faxclienta", "").
                           next.
                        end.
                        if v-str matches "*rnnclienta*" then do:
                           v-str = replace (v-str, "rnnclienta", string(cif.jss) ).
                           next.
                        end.
                        if v-str matches "*iikclienta*" then do:
                           v-str = replace (v-str, "iikclienta", aaa.aaa ).
                           next.
                        end.
                       /*Данные филиала*/
                        if v-str matches "*danniefil*" then do:
                           v-str = replace (v-str, "danniefil", v-bickfiliala).
                           next.
                        end.
                        if v-str matches "*bickfilialakz*" then do:
                           v-str = replace (v-str, "bickfilialakz", v-bickfilialakz).
                           next.
                        end.
                        leave.
                     end.
                     put stream v-out unformatted v-str skip.
                end.
                input close.
                output stream v-out close.
                unix silent cptunkoi value(v-ofile) winword.
                message  "  ВНИМАНИЕ! "
                skip(5) "   ПРОВЕРЬТЕ ТЕКСТ ДОГОВОРА!  "
                skip "      При обнаружении ошибок сообщите в ДИТ.    "
                skip(5)  view-as alert-box question buttons ok title "" .
           end.
       v-ans = false.
   end.
   end.
  if v-ans = false then leave.
 end. /*repeat*/
 /*message "ext" view-as alert-box.*/
end.

else if opt eq "C" then do trans on error undo, retry:
        prompt-for v-aaacif with centered color message frame aaa.
        s-aaa = input v-aaacif.
        find aaa where aaa.aaa eq s-aaa.
        find cif where cif.cif eq aaa.cif.
        find lgr where lgr.lgr eq aaa.lgr.
        find led where led.led eq lgr.led.
        if keyfunction(lastkey) eq "GO" or keyfunction(lastkey) eq "RETURN"
        then do:
           {print-dolg2.i}.
           aaa.penny = in_command.   /*Величина Комиссии*/
           aaa.vip = V-sel.      /*  код выбранного пункта меню  */
           if led.prgedt ne "" then run value(led.prgedt).
      /*   message  "v-sel =" v-sel "s-aaa = " s-aaa. pause 200.*/
        end.
        hide all /*aaa*/.
     end.
else if opt = "D"  then do trans on error undo, retry:
        find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
        if not avail sysc then do:
          message "Не найден параметр ourbnk в sysc!" view-as alert-box.
          undo, retry.
        end.
        v-bank = sysc.chval.

        find first txb where txb.bank = v-bank and txb.consolid no-lock.
        if avail txb then vfilecls =  '/data/log/b' + entry(3,txb.path,'/') + '/'.
        else vfilecls = '/data/log/'.
        vfilecls = vfilecls + 'aaaclsofc' + string(day(g-today),'99') + string(month(g-today),'99') + string(year(g-today),'9999') + '.txt'.
        output stream aaaclsofc to value(vfilecls) append.
        prompt-for v-aaacif with centered side-label color message frame aaa.
        s-aaa = input v-aaacif.
        find aaa where aaa.aaa eq s-aaa.
        find lgr where lgr.lgr eq aaa.lgr.
        find led where led.led eq lgr.led.
        bell.
        {mesg.i 0824} update vans.
       if vans then do:
         if length(s-aaa) = 20 then do:
           find first b-aaa where b-aaa.aaa20 = s-aaa no-error.
           if avail b-aaa then b-aaa.aaa20 = ''.
         end.
         if aaa.cdt ne ? or aaa.ddt ne ? then do:
            bell.
            {mesg.i 2202}.
            undo, retry.
         end.
         if can-find(first aal of aaa) then do:
            bell.
            {mesg.i 2202}.
            undo, retry.
          end.
          if aaa.dr[1] ne 0 or aaa.cr[1] ne 0 then do:
            bell.
            {mesg.i 2202}.
            undo, retry.
          end.
          if can-find(first trxbal where trxbal.subled = 'cif' and trxbal.acc = aaa.aaa and
             (trxbal.dam ne 0 or cam ne 0)) then do:
            bell.
            {mesg.i 2202}.
            undo, retry.
          end.
          for each sub-cod where sub-cod.sub = 'cif'
                             and sub-cod.acc = aaa.aaa.
              delete sub-cod.
          end.
          find bxcif where bxcif.cif = aaa.cif and bxcif.aaa = aaa.aaa no-error.
          if available bxcif then do:
           message "У клиента задол-ть за открытие счета " aaa.aaa "на сумму " aaa.penny "USD. Удалить ?" update v-log.
             if v-log then  delete bxcif.
           end.

           put stream aaaclsofc unformatted "Закрыт счет " aaa.cif " " aaa.aaa " группа счета " aaa.lgr " менеджер " g-ofc " дата закрытия " string(g-today,'99/99/9999') " время " string(time,'hh:mm:ss') skip.
           output stream aaaclsofc close.

/*begin*07/06/2013 galina - ТЗ1822***/
           v-garnum = ''. v-gardt = ?.
           if string(aaa.gl) matches '2240*' then do:
              find first garan where garan.garan = aaa.aaa exclusive-lock no-error.
              if avail garan then do:
                  v-garnum = garan.garnum.
                  v-gardt = string(garan.dtfrom).
                  delete garan.
                  message  "Удален договор гарантии N " + v-garnum + " от " + v-gardt view-as alert-box title "ВНИМАНИЕ" .
              end.
           end.
/*end*07/06/2013 galina - ТЗ1822***/

          delete aaa.

         {mesg.i 2201}.

       end.
       hide frame aaa.
    end.


procedure defdts:
def input parameter p-dt as date.
def output parameter p-datastr as char.
def output parameter p-datastrkz as char.

def var v-monthname as char init
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".

def var v-monthnamekz as char init
   "&#1179;а&#1187;тар,а&#1179;пан,наурыз,с&#1241;уiр,мамыр,маусым,шiлде,тамыз,&#1179;ырк&#1199;йек,&#1179;азан,&#1179;араша,желто&#1179;сан".
p-datastr = entry(month(p-dt), v-monthname).
p-datastrkz = entry(month(p-dt), v-monthnamekz).

end.


procedure defdts1:
def input parameter p-rdt as date.
def input parameter p-edt as date.
def output parameter p-datastr as char.
def output parameter p-datastrkz as char.

def var v-monthname as char init
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".

def var v-monthnamekz1 as char init
   "&#1179;а&#1187;тарынан,а&#1179;панынан,наурызынан,с&#1241;уiрiнен,мамырынан,маусымынан,шiлдесінен,тамызынан,&#1179;ырк&#1199;йегінен,
   &#1179;азанынан,&#1179;арашасынан,желто&#1179;санынан".
def var v-monthnamekz2 as char init
   "&#1179;а&#1187;тарына,а&#1179;панына,наурызына,с&#1241;уiріне,мамырына,маусымына,шiлдесіне,тамызына,
    &#1179;ырк&#1199;йегіне,&#1179;азанына,&#1179;арашасына,желто&#1179;санына".

p-datastr = "c «" + string(day(p-rdt),"99") + "» " + entry(month(p-rdt), v-monthname)  + " " + string(year(p-rdt)) +
       " г. по «" + string(day(p-edt),"99") + "» " + entry(month(p-edt), v-monthname)  + " " + string(year(p-edt)) + " г.".

p-datastrkz = string(year(p-rdt)) + " ж. «" + string(day(p-rdt),"99") + "» " + entry(month(p-rdt), v-monthnamekz1) + " " +
              string(year(p-edt)) + " ж. «" + string(day(p-edt),"99") + "» " + entry(month(p-edt), v-monthnamekz2) + " дейін".

end.


procedure defval:
def input parameter p-sum as decimal.
def input parameter p-crc as integer.
def output parameter p-valrus as char.
def output parameter p-valkz as char.

def buffer buf-crc for crc.

def var nEd  as decimal.
def var nDec as decimal.

def var s as char.
def var s1 as char.

find first buf-crc where buf-crc.crc = p-crc no-lock no-error.

s = buf-crc.deskz[3].
s1 = buf-crc.deskz[2].


nEd  = p-sum modulo 10.
nDec = p-sum modulo 100.


if (nDec >= 11 and nDec <= 14) or (nEd >= 5 and nEd <= 9) or (nEd = 0) then do:
   p-valrus = entry(3, s).
   p-valkz = entry(3, s1).
end.
else if (nEd = 1) then do:
        p-valrus = entry(1, s).
        p-valkz = entry(1, s1).
     end.
     else do:
        p-valrus = entry(2, s).
        p-valkz = entry(2, s1).
     end.
end.


procedure defddmm:
def input parameter p-count as integer.
def output parameter p-ddrus as char.
def output parameter p-ddkz as char.
def output parameter p-mmrus as char.
def output parameter p-mmkz as char.


def var nEd  as decimal.
def var nDec as decimal.

def var mm as char.
def var mm1 as char.
def var dd as char.
def var dd1 as char.


mm = "ай,ай,ай".
mm1 = "месяц,месяца,месяцев".

dd = "к&#1199;н,к&#1199;н,к&#1199;н".
dd1 = "день,дня,дней".



nEd  = p-count modulo 10.
nDec = p-count modulo 100.


if (nDec >= 11 and nDec <= 14) or (nEd >= 5 and nEd <= 9) or (nEd = 0) then do:
   p-ddrus = entry(3, dd1).
   p-ddkz = entry(3, dd).
   p-mmrus = entry(3, mm1).
   p-mmkz = entry(3, mm).
end.
else if (nEd = 1) then do:
       p-ddrus = entry(1, dd1).
       p-ddkz = entry(1, dd).
       p-mmrus = entry(1, mm1).
       p-mmkz = entry(1, mm).
     end.
     else do:
       p-ddrus = entry(2, dd1).
       p-ddkz = entry(2, dd).
       p-mmrus = entry(2, mm1).
       p-mmkz = entry(2, mm).
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


/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifexhis_update.
create tarifexhis.
buffer-copy tarifex to tarifexhis.
end procedure.

procedure tarifex2his_update.
create tarifex2his.
buffer-copy tarifex2 to tarifex2his.
end procedure.
