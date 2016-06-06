/* checotm.p
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
        BANK        
 * CHANGES
        07.10.05 dpuchkov добавил серию чека
        07/10/2009 galina - забросила в библиотеку
*/

/*checotm.p*/

{global.i}
def new shared var s-jh like jh.jh.
def var v1 as integer initial 000025.
def var v3 as integer initial 25.
def var v2 as integer initial 000024.
def var pirmno as int.
def var otrno as int.
def var c-non like checks.nono.
def var c-lid like checks.lidzno.
def var c-pri like checks.prizn.
def var c-cel like checks.celon.
def var s-cif like checks.cif.
def var ok as int.
def var kk as int.
def var trnu as int format "zzzzzzz9" init 0.
def var antr as logical.
def var rcode   as integer.
def var tcode   as integer.
def var tdes    as char.


MESSAGE "Введите номер аннулируемой транзакции".
UPDATE trnu LABEL "Номер аннулируемой транзакции" WITH SIDE-LABELS  FRAME vasa.

find jh where jh.jh eq trnu no-lock no-error.
if not available jh then do:
    message "Транзакция " jh.jh
    " не найдена. Обратитесь к администратору".
    pause .
    leave.
end.
else do:
    antr = false.
    message "Аннулировать транзакцию ?" update antr.
    if antr then do:
        s-jh = jh.jh.
        if jh.sts eq 6 then do:
            message "Транзакция с 6 статусом!!".
            pause.
            leave.
        end.
        run trxdelun(input s-jh).
        if tcode ne 0 then do:
            message tdes.
            pause.
            leave.
        end.
        do transaction:
            for each checks where checks.jh eq s-jh:
                find first gram where gram.nono = checks.nono and
                gram.lidzno = checks.lidzno and gram.ser = checks.ser  no-error.
                if available gram then do:
                    gram.izmatz = " ".
                    gram.anuatz = " ".
                    gram.cif = " ".
                    gram.atzdat = ?.
                    gram.atzwho = " " .
                    gram.ser = "".
                end.
                delete checks.
            end.
        end.
    end.
end.
