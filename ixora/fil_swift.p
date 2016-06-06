/* fil_swift.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR

 * BASES
        BANK COMM

 * CHANGES
        07.12.2011 Luiza
        24/02/2012 dmitriy - изменил формат для Наименования получателя на "x(60)"
        06/03/2012 Luiza - расширила поле v_namepol до 85 символов
        16/03/2012 Luiza - для рублей, если бик не найден - пропускаем
        20/032012  Luiza - изменила если бик для RU не найден вводим бик и наименование банка
        27/08/2012 Luiza - если ввели код ABA бик не ищем
*/

def input parameter v-ll as char.
def output parameter v-stoplist1 as logic.
def var v_rep as int.
def var v-sw as logic format "Да/Нет" init yes.
/*def var yn as logic  format "Да/Нет" init no.*/
def  shared var v_bank as char format "x(50)" no-undo.
def  shared var v_numch1 as char format "x(50)" no-undo.
def  shared var v_bank1 as char format "x(50)" no-undo.
def  shared var v_bank2 as char format "x(50)" no-undo.
def  shared var v_chpol as char format "x(50)" no-undo.
def  shared var v_innpol as char format "x(12)" no-undo.
def  shared var v_namepol as char format "x(50)" no-undo.
def  shared var v_oper as char format "x(140)" no-undo.
def  shared var v_swcod as char format "x(1)"  no-undo.
def  shared var v_swcity as char format "x(35)" no-undo.
def  shared var v_swcnt as char format "x(35)" no-undo.
def  shared var v_swcod1 as char format "x(1)"  no-undo.
def  shared var v_swcity1 as char format "x(35)" no-undo.
def  shared var v_swcnt1 as char format "x(35)" no-undo.
def  shared var v_swbic as char format "x(35)" no-undo.
def  shared var v_swbic1 as char format "x(35)" no-undo.
def  shared var v_countr1 as char format "x(35)" no-undo.
def  shared var v_crc as int no-undo.
def var v_find as logic init no.
def var v_find1 as logic init no.

 /*v_swcod  = "".
 v_swcity = "".
 v_swcnt = "".
 v_swcod1 = "".
 v_swcity1 = "".
 v_swcnt1 = "".
 v_swbic = "".
 v_swbic1 = "".*/

function num1 returns logic (t as char).
	def var num as char extent 10 init ["1","2","3","4","5","6", "7","8","9","0"].
	def var i as integer.
	def var j as integer.
	def var ch as logic.
	i = 1.
    repeat:
        ch = no.
        do j = 1 to 10:
            if substr(t,i,1) = num[j] then ch = yes.
        end.
        i = i + 1.
        if ch = no then return ch.
        if i > length(t) then leave.
    end.
    return ch.
end.


def var ch1 as logic.

DEFINE QUERY q-numch2 FOR swibic.
DEFINE BROWSE b-numch2 QUERY q-numch2
       DISPLAY swibic.bic label "Бик " format "x(11)" swibic.name label "Наименование " format "x(60)"  WITH  10 DOWN.
DEFINE FRAME f-numch2 b-numch2  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 15 width 90 NO-BOX.

DEFINE QUERY q-numch3 FOR swibic.
DEFINE BROWSE b-numch3 QUERY q-numch3
       DISPLAY swibic.bic label "Бик " format "x(11)" swibic.name label "Наименование " format "x(60)"  WITH  10 DOWN.
DEFINE FRAME f-numch3 b-numch3  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 15 width 90 NO-BOX.

DEFINE QUERY q-numch4 FOR swibic.
DEFINE BROWSE b-numch4 QUERY q-numch4
       DISPLAY swibic.bic label "Бик " format "x(11)" swibic.name label "Наименование " format "x(60)"  WITH  10 DOWN.
DEFINE FRAME f-numch4 b-numch4  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 15 width 90 NO-BOX.

/*DEFINE QUERY q-country1 FOR codfr.
DEFINE BROWSE b-country1 QUERY q-country1
       DISPLAY codfr.code label "Код " format "x(3)" codfr.name[1] label "Наименование " format "x(30)"  WITH  10 DOWN.
DEFINE FRAME f-country1 b-country1  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 40 width 50 NO-BOX.*/


    form
                    "Бик банка-корресп-та:" skip
    v_swbic      no-label /*validate(can-find(first bankl where bankl.bank = v_bank or trim(v_bank) = "" no-lock),
                "Неверное наименование банк-корресп-та")*/ help "Введите SWIFT бик" format "x(30)"  skip
                    "Наименование банка-корресп-та:" skip
    v_bank      no-label /*validate(can-find(first bankl where bankl.bank = v_bank or trim(v_bank) = "" no-lock),
                "Неверное наименование банк-корресп-та")*/ help "Введите наименование банка-корресп-та" format "x(80)"  skip
                      "Ном счета банка получателя в банке-корресп:" skip
    v_numch1     no-label  format "x(50)" skip
                      "Бик банка получателя:" skip
    v_swbic1     no-label help "Введите SWIFT бик" format "x(30)" skip
                      "Наименование банка получателя:" skip
    v_bank1     no-label validate(trim(v_bank1) <> "" , "Введите наименование") format "x(80)" skip
    v_bank2     no-label  format "x(80)" skip
                      "Номер счета получателя в банке получателя:" skip
    v_chpol     no-label validate(trim(v_chpol) <> "" , "Введите номер счета") format "x(50)"  skip
                      "Наименование получателя: " skip
    v_namepol   no-label validate(trim(v_namepol) <> "" , "Введите наименование получателя") format "x(85)"  skip
    v_innpol    label "ИНН получателя "  format "x(12)" skip
        v-sw label " Перенести данные в свифт - макет?.............."   skip
        WITH  SIDE-LABELS overlay ROW 7 column 10
        TITLE "Данные для свифт - макета" width 90  FRAME f-swift.

    form
    v_swcity label "Город местонахождения банка" validate(trim(v_swcity) <> "", "Введите название города на англ языке") help "Введите название города на англ языке" format "x(35)" skip
    v_swcnt label "Страна местонахождения банка" validate(trim(v_swcnt) <> "", "Введите название страны на англ языке") help "Введите название страны на англ языке" format "x(35)" skip
        WITH  SIDE-LABELS overlay ROW 21 column 10
        TITLE "Данные для свифт - макета" width 90  FRAME f-swift1.
    form
    v_swcity1 label "Город местонахождения банка" validate(trim(v_swcity1) <> "", "Введите название города на англ языке") help "Введите название города на англ языке" format "x(35)" skip
    v_swcnt1 label "Страна местонахождения банка" validate(trim(v_swcnt1) <> "", "Введите название страны на англ языке") help "Введите название страны на англ языке" format "x(35)" skip
        WITH  SIDE-LABELS overlay ROW 21 column 10
        TITLE "Данные для свифт - макета" width 90  FRAME f-swift2.

on help of v_bank in frame f-swift do:
    OPEN QUERY  q-numch2 FOR EACH swibic no-lock.
    ENABLE ALL WITH FRAME f-numch2.
    wait-for return of frame f-numch2
    FOCUS b-numch2 IN FRAME f-numch2.
    v_swbic = swibic.bic.
    v_bank = swibic.name.
    hide frame f-numch2.
    displ v_swbic v_bank with frame f-swift.
end.
on help of v_swbic in frame f-swift do:
    OPEN QUERY  q-numch2 FOR EACH swibic no-lock.
    ENABLE ALL WITH FRAME f-numch2.
    wait-for return of frame f-numch2
    FOCUS b-numch2 IN FRAME f-numch2.
    v_swbic = swibic.bic.
    v_bank = swibic.name.
    hide frame f-numch2.
    displ v_swbic v_bank with frame f-swift.
end.

on help of v_bank1 in frame f-swift do:
    OPEN QUERY  q-numch2 FOR EACH swibic no-lock.
    ENABLE ALL WITH FRAME f-numch2.
    wait-for return of frame f-numch2
    FOCUS b-numch2 IN FRAME f-numch2.
    v_swbic1 = swibic.bic.
    v_bank1 = swibic.name.
    hide frame f-numch2.
    displ v_swbic1 v_bank1 with frame f-swift.
end.
on help of v_swbic1 in frame f-swift do:
    OPEN QUERY  q-numch2 FOR EACH swibic no-lock.
    ENABLE ALL WITH FRAME f-numch2.
    wait-for return of frame f-numch2
    FOCUS b-numch2 IN FRAME f-numch2.
    v_swbic1 = swibic.bic.
    v_bank1 = swibic.name.
    hide frame f-numch2.
    displ v_swbic1 v_bank1 with frame f-swift.
end.

on "END-ERROR" of v_swbic1 in frame f-swift do:
end.
on "END-ERROR" of v_swbic in frame f-swift do:
end.

v-stoplist1 = no.
v-sw = yes.
/*update v_countr1 with frame f-swift.*/
    displ v_swbic    v_bank  v_numch1   v_swbic1  v_bank1  v_bank2 v_chpol  v_namepol v_innpol  with frame f-swift.
    pause 0.
if v_crc <> 4 then do:
    /* for bank corresp*/
    REPEAT :
        v_find = no.
        v_swcod = "D".
        update v_swbic  with frame f-swift.
        if v_swbic <> "" then do:
            find first swibic where swibic.bic = trim(v_swbic) no-lock no-error.
            if available swibic then do:
                v_bank = swibic.name.
                v_swbic = swibic.bic.
                v_swcod = "A".
                v_swcity = swibic.city.
                v_swcnt = swibic.cnt.
                displ v_swbic v_bank with frame f-swift.
                v_find = yes.
                find first stoplist where stoplist.code = substr(v_swbic,5,2) no-lock no-error.
                if avail stoplist and stoplist.sts <> 9 then do:
                    message "Операция запрещена! Указан БИК страны из СТОП-ЛИСТа!" view-as alert-box.
                    /* v-stoplist1 = yes. */
                    v_find = no.
                end.
            end. /* available swibic*/
            else do:
                find first swibic where swibic.bic begins trim(v_swbic) no-lock no-error.
                if available swibic then do:
                    OPEN QUERY  q-numch3 FOR EACH swibic where swibic.bic begins trim(v_swbic) no-lock.
                    ENABLE ALL WITH FRAME f-numch3.
                    wait-for return of frame f-numch3
                    FOCUS b-numch3 IN FRAME f-numch3.
                    v_bank = swibic.name.
                    v_swbic = swibic.bic.
                    v_swcod = "A".
                    v_swcity = swibic.city.
                    v_swcnt = swibic.cnt.
                    hide frame f-numch3.
                    displ v_swbic v_bank with frame f-swift.
                    v_find = yes.
                    find first stoplist where stoplist.code = substr(v_swbic,5,2) no-lock no-error.
                    if avail stoplist and stoplist.sts <> 9 then do:
                        message "Операция запрещена! Указан банк страны из СТОП-ЛИСТа!" view-as alert-box.
                        /* v-stoplist1 = yes.*/
                        v_find = no.
                    end.
                end. /* available swibic*/
            end. /*   else do */
        end. /* if v_swbic <> "" */

        if  trim(v_swbic) = "" or not available swibic then do: /* eсли бик пустой ищем по названию  */

            update v_bank with frame f-swift.
            if v_bank <> "" then do:
               /* find first swibic where swibic.name = trim(v_bank) no-lock no-error.
                if available swibic then do:
                    v_bank = swibic.name.
                    v_swbic = swibic.bic.
                    v_swcod = "A".
                    v_swcity = swibic.city.
                    v_swcnt = swibic.cnt.
                    displ v_swbic v_bank with frame f-swift.
                    find first stoplist where stoplist.code = substr(v_swbic,5,2) no-lock no-error.
                    if avail stoplist and stoplist.sts <> 9 then do:
                        message "Операция запрещена! Указана страна из СТОП-ЛИСТа!" view-as alert-box.
                        v-stoplist1 = yes.
                        return.
                    end.
                end.
                else do:*/
                    find first swibic where swibic.name BEGINS trim(v_bank) no-lock no-error.
                    if available swibic then do:
                        OPEN QUERY  q-numch3 FOR EACH swibic where swibic.name BEGINS trim(v_bank) no-lock.
                        ENABLE ALL WITH FRAME f-numch3.
                        wait-for return of frame f-numch3
                        FOCUS b-numch3 IN FRAME f-numch3.
                        v_bank = swibic.name.
                        v_swbic = swibic.bic.
                        v_swcod = "A".
                        v_swcity = swibic.city.
                        v_swcnt = swibic.cnt.
                        hide frame f-numch3.
                        displ v_swbic v_bank with frame f-swift.
                        v_find = yes.
                        find first stoplist where stoplist.code = substr(v_swbic,5,2) no-lock no-error.
                        if avail stoplist and stoplist.sts <> 9 then do:
                            message "Операция запрещена! Указана страна из СТОП-ЛИСТа!" view-as alert-box.
                            /* v-stoplist1 = yes.*/
                            v_find = no.
                        end.
                    end.
                    /*else do:
                        message "Банк не найден, укажите город и страну нахождения банка" view-as alert-box.
                        ch1 = no.
                        update v_swcity v_swcnt with frame f-swift1.
                        repeat:
                            run eng(v_swcity, output ch1).
                            if ch1 = yes then do:
                                message "Есть символы русского алфавита, необходимо исправить".
                                pause 3.
                                update v_swcity with frame f-swift1.
                            end.
                            else leave.
                        end.
                        repeat:
                            run eng(v_swcnt, output ch1).
                            if ch1 = yes then do:
                                message "Есть символы русского алфавита, необходимо исправить".
                                pause 3.
                                update v_swcnt with frame f-swift1.
                            end.
                            else leave.
                        end.
                        find first stoplist where stoplist.country = v_swcnt no-lock no-error.
                        if avail stoplist and stoplist.sts <> 9 then do:
                            message "Операция запрещена! Указана страна из СТОП-ЛИСТа!" view-as alert-box.
                            v-stoplist1 = yes.
                            return.
                        end.
                    end.*/
               /*end.*/
                hide frame f-swift1.
                update v_numch1 with frame f-swift.
            end.
            else v_swcod = "N".
        end.

    /* for bank poluch*/
        v_find1 = no.
        update v_swbic1 with frame f-swift.
        if v_swbic1 <> "" then do:
            find first swibic where swibic.bic = trim(v_swbic1) no-lock no-error.
            if available swibic then do:
                v_bank1 = swibic.name.
                v_swbic1 = swibic.bic.
                v_swcod1 = "A".
                v_swcity1 = swibic.city.
                v_swcnt1 = swibic.cnt.
                displ v_swbic1 v_bank1 with frame f-swift.
                v_find1 = yes.
                find first stoplist where stoplist.code = substr(v_swbic1,5,2) no-lock no-error.
                if avail stoplist and stoplist.sts <> 9 then do:
                    message "Операция запрещена! Указан бик страны из СТОП-ЛИСТа!" view-as alert-box.
                    /* v-stoplist1 = yes.*/
                    v_find1 = no.
                end.
            end. /* if available swibic */
            else do:
                find first swibic where swibic.bic begins trim(v_swbic1) no-lock no-error.
                if available swibic then do:
                    OPEN QUERY  q-numch3 FOR EACH swibic where swibic.bic begins trim(v_swbic1) no-lock.
                    ENABLE ALL WITH FRAME f-numch3.
                    wait-for return of frame f-numch3
                    FOCUS b-numch3 IN FRAME f-numch3.
                    v_bank1 = swibic.name.
                    v_swbic1 = swibic.bic.
                    v_swcod1 = "A".
                    v_swcity1 = swibic.city.
                    v_swcnt1 = swibic.cnt.
                    hide frame f-numch3.
                    displ v_swbic1 v_bank1 with frame f-swift.
                    v_find1 = yes.
                    find first stoplist where stoplist.code = substr(v_swbic,5,2) no-lock no-error.
                    if avail stoplist and stoplist.sts <> 9 then do:
                        message "Операция запрещена! Указан банк страны из СТОП-ЛИСТа!" view-as alert-box.
                        /*v-stoplist1 = yes.*/
                        v_find1 = no.
                    end.
                end. /* if available swibic */
            end. /* else do  */
        end.
        if (trim(v_swbic1)  = ""  or not available swibic) and not num1(v_swbic1) then do: /* eсли бик не найден ищем по названию  */
            v_swcod1 = "D".
            update v_bank1 with frame f-swift.
            find first swibic where  swibic.name = v_bank1 no-lock no-error.
            if available swibic then do:
                v_bank1 = swibic.name.
                v_swbic1 = swibic.bic.
                v_swcod1 = "A".
                v_swcity1 = swibic.city.
                v_swcnt1 = swibic.cnt.
                displ v_swbic1 v_bank1 with frame f-swift.
                v_find1 = yes.
                find first stoplist where stoplist.code = substr(v_swbic1,5,2) no-lock no-error.
                if avail stoplist and stoplist.sts <> 9 then do:
                    message "Операция запрещена! Указан БИК страны из СТОП-ЛИСТа!" view-as alert-box.
                    /*v-stoplist1 = yes.*/
                    v_find1 = no.
                end.
            end.  /*  if available swibic */
            else do:
                find first swibic where swibic.name BEGINS trim(v_bank1) no-lock no-error.
                if available swibic then do:
                    OPEN QUERY  q-numch3 FOR EACH swibic where  swibic.name BEGINS trim(v_bank1) no-lock.
                    ENABLE ALL WITH FRAME f-numch3.
                    wait-for return of frame f-numch3
                    FOCUS b-numch3 IN FRAME f-numch3.
                    v_bank1 = swibic.name.
                    v_swbic1 = swibic.bic.
                    v_swcod1 = "A".
                    v_swcity1 = swibic.city.
                    v_swcnt1 = swibic.cnt.
                    hide frame f-numch3.
                    displ v_swbic1 v_bank1 with frame f-swift.
                    v_find1 = yes.
                    find first stoplist where stoplist.code = substr(v_swbic1,5,2) no-lock no-error.
                    if avail stoplist and stoplist.sts <> 9 then do:
                        message "Операция запрещена! Указан банк страны из СТОП-ЛИСТа!" view-as alert-box.
                        /*v-stoplist1 = yes.*/
                        v_find1 = no.
                    end.
                end. /*  if available swibic */
            end. /*  else do:  */
        end. /* if trim(v_swbic1)  = ""  */
        if (v_find = yes and (v_swbic = "" and v_bank = "")) or v_find1 = yes then leave.
        if not num1(v_swbic1) then message "Бик банка не найден" VIEW-AS ALERT-BOX.
        else do:
            message "Бик банка не найден, пропустить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE yn1 AS LOGICAL.
            if yn1  then do:
                v_swcod1 = "D".
                update v_bank1 with frame f-swift.
                leave.
            end.
        end.
    end. /* repeat  */
    if keyfunction (lastkey) = "end-error" then do:
        v-stoplist1 = yes.
        message "Документ не сохранится!" view-as alert-box.
        return.
    end.

    update v_chpol v_namepol with frame f-swift.

    REPEAT :
        run eng(v_namepol, output ch1).
        if ch1 = yes then do:
            message "Наименование введите по англ!".
            pause 3.
            update v_namepol with frame f-swift.
        end.
        else leave.
    end.
    update v_innpol v-sw with frame f-swift.
end. /* if v_crc <> 4   */

    /* for bank poluch  ru--------------------------------------------------------------------------*/
else do:
    REPEAT:
        v_find = no.
        update v_swbic1 with frame f-swift.
        find first swibic where swibic.bic = v_swbic1 no-lock no-error.
        if available swibic then do:
            v_bank1 = swibic.name.
            v_swbic1 = swibic.bic.
            v_swcod1 = "D".
            v_swcity1 = swibic.city.
            v_swcnt1 = swibic.cnt.
            displ v_swbic1 v_bank1 with frame f-swift.
            v_find = yes.
            update v_bank2 with frame f-swift.
        end.
        else do:
            if trim(v_swbic1) <> "" then do:
                find first swibic where swibic.bic begins trim(v_swbic1)  no-lock no-error.
                if available swibic then do:
                    OPEN QUERY  q-numch4 FOR EACH swibic where swibic.bic begins trim(v_swbic1) no-lock.
                    ENABLE ALL WITH FRAME f-numch4.
                    wait-for return of frame f-numch4
                    FOCUS b-numch4 IN FRAME f-numch4.
                    v_bank1 = swibic.name.
                    v_swbic1 = swibic.bic.
                    v_swcod1 = "A".
                    v_swcity1 = swibic.city.
                    v_swcnt1 = swibic.cnt.
                    hide frame f-numch4.
                    displ v_swbic1 v_bank1 with frame f-swift.
                    v_find = yes.
                    update v_bank2 with frame f-swift.
                end.
            end.
        end.
        if trim(v_swbic1) = "" then do: /* eсли бик пустой ищем по названию  */
            update v_bank1 with frame f-swift.
            find first swibic where swibic.name = v_bank1 no-lock no-error.
            if available swibic then do:
                v_bank1 = swibic.name.
                v_swbic1 = swibic.bic.
                v_swcod1 = "D".
                v_swcity1 = swibic.city.
                v_swcnt1 = swibic.cnt.
                displ v_bank1 with frame f-swift.
                v_find = yes.
                update v_bank2 with frame f-swift.
            end.
            else do:
                find first swibic where swibic.name BEGINS trim(v_bank1) no-lock no-error.
                if available swibic then do:
                    OPEN QUERY  q-numch4 FOR EACH swibic where swibic.name BEGINS trim(v_bank1) no-lock.
                    ENABLE ALL WITH FRAME f-numch4.
                    wait-for return of frame f-numch4
                    FOCUS b-numch4 IN FRAME f-numch4.
                    v_bank1 = swibic.name.
                    v_swbic1 = swibic.bic.
                    v_swcod1 = "A".
                    v_swcity1 = swibic.city.
                    v_swcnt1 = swibic.cnt.
                    hide frame f-numch4.
                    displ v_bank1 with frame f-swift.
                    v_find = yes.
                    update v_bank2 with frame f-swift.
                end.
                   /* else do:
                        message "Банк не найден, пропустить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE yn AS LOGICAL.
                        if yn  then do: v_bank1 = "". displ v_bank1 with frame f-swift. leave. end.
                    end.
                    hide message no-pause.*/
            end. /*  else do: */
        end. /*  if trim(v_swbic1) = "" */
        /*if v_find = yes then leave.
        message "Банк не найден!" view-as alert-box.*/
        if v_find = no then do:
            message "Банк не найден, пропустить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE yn AS LOGICAL.
            if yn  then do:
                update v_bank1 v_bank2 with frame f-swift.
                leave.
            end.
        end.
        else leave.
    end. /* repeat  */
    if keyfunction (lastkey) = "end-error" then do:
        v-stoplist1 = yes.
        message "Документ не сохранится!" view-as alert-box.
        return.
    end.

    REPEAT ON ENDKEY UNDO, RETRY:
        update v_chpol v_namepol v_innpol v-sw with frame f-swift.
        if length(v_chpol) = 20 then leave.
        else  message "В России 20-значные счета" .
    end.

end. /* else do  */
hide frame f-swift.
hide frame f-swift1.
hide frame f-swift2.
return.

procedure eng:
    define input parameter t as char.
    def output parameter ch as logic.
	def var rus as char extent 33 init ["А","Б","В","Г","Д","Е", "Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф", "Х","Ц", "Ч", "Ш", "Щ",  "Ъ","Ы", "Ь", "Э", "Ю", "Я"].
	def var i as integer.
	def var j as integer.
	t = caps(t).
	i = 1.
    ch = no.
	repeat:
	 do j = 1 to 33:
	    if substr(t,i,1) = rus[j] then ch = yes.
	 end.
	 i = i + 1.
	 if i > length(t) then leave.
	end.
end procedure.

