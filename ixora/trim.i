/* trim.i
 * MODULE
        Pragma
 * DESCRIPTION
        Строковые функции - глобальная замена, trim, транслитерация в англ. язык
        Функции для урезания ненужных символов...
        Все названия как в Прогресс, но с "G" = "Global"...
 * RUN
        А там понятно написано
 * CALLER
        много много процедур
 * SCRIPT
        Нет скриптов
 * INHERIT
        Все внутри себя вызывает
 * MENU
        много много процедур
 * AUTHOR
        11/02/03 sasco
 * CHANGES
        11/08/03 sasco Добавил в GReplace проверку на нулевую строку
                        (которая для замены) - в связи с переходом на Progress-9
        10/12/04 sasco Замена Ё -> Е, Й -> И
*/

/* ------------------------------------------------ */
/* Проверка на предыдущий GLOBAL-DEFINE переменной  */
/* ------------------------------------------------ */
     &IF DEFINED (G_STRING_TRIMMING_FUNCTIONS) <> 1 
/* ------------------------------------------------ */
                       &THEN
/* ------------------------------------------------ */
     &GLOBAL-DEFINE G_STRING_TRIMMING_FUNCTIONS
/* ------------------------------------------------ */
/* ------------------------------------------------ */

/* - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* GReplace: рекурсивная замена всех символов в строке */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - */
function GReplace returns char (sfrom as char, s1 as char, s2 as char).
   def var sprev as char NO-UNDO.
   def var scurr as char NO-UNDO.

   if length (s1) = 0 then return sfrom.

   sprev = ''.
   scurr = sfrom.
   do while length (sprev) <> length (scurr):
      sprev = scurr.
      scurr = REPLACE (scurr, s1, s2).
   end.
   return scurr.
end function.


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* GTrim: уничтожение пробелов на концах и двойных в середине */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
function GTrim returns char (sfrom as char).
    return GReplace (TRIM(sfrom), "  ", " ").
end function.


/* - - - - - - - - - - - - - - - - - - - - -*/
/* GSTrim: уничтожение специальных символов */
/* - БЕЗ ПРОБЕЛОВ! ! ! -                    */
/* - - - - - - - - - - - - - - - - - - - - -*/
function GSTrim returns char (sfrom as char).
    def var i as int NO-UNDO.
    def var tstr as char NO-UNDO.
    tstr = GTrim (sfrom).
    do i =  33 to  37: tstr = GReplace (tstr, CHR(i), ""). end.
    do i =  39 to  42: tstr = GReplace (tstr, CHR(i), ""). end.

    /*  ? обработка плюса (43) */
    tstr = GReplace (tstr, CHR(43), "").

    /*  ? обработка минуса (45) */ 
    do i =  44 to  47: tstr = GReplace (tstr, CHR(i), ""). end. 
    
    do i =  58 to  64: tstr = GReplace (tstr, CHR(i), ""). end.
    do i =  91 to  96: tstr = GReplace (tstr, CHR(i), ""). end.
    do i = 123 to 162: tstr = GReplace (tstr, CHR(i), ""). end.
    do i = 164 to 178: tstr = GReplace (tstr, CHR(i), ""). end.
    do i = 180 to 191: tstr = GReplace (tstr, CHR(i), ""). end.
    return tstr.
end function.


/* - - - - - - - - - - - - - - - - - - - - - */
/* GPSTrim: уничтожение специальных символов */
/* - С ПРОБЕЛАМИ! ! ! !-                     */
/* - - - - - - - - - - - - - - - - - - - - - */
function GPSTrim returns char (sfrom as char).
    def var i as int NO-UNDO.
    def var tstr as char NO-UNDO.
    tstr = GReplace (sfrom, " ", "").
    tstr = GSTrim (tstr).
    return tstr.
end function.


/* - - - - - - - - - - - - - - - - - - - */
/* GEnglish: транслитерация по-английски */
/* возщвращает все вимволы в CAPS()      */
/* - - - - - - - - - - - - - - - - - - - */
function GEnglish returns char (sfrom as char).
    def var tstr as char NO-UNDO.
    tstr = sfrom.
    tstr = replace (tstr, "Ё", "Е").
    tstr = replace (tstr, "ё", "е").
    tstr = replace (tstr, "Й", "И").
    tstr = replace (tstr, "й", "и").
    tstr = CAPS (tstr).
    run rus2eng (input-output tstr).
    return tstr.
end function.


/* - - - - - - - - - - - - - - - - - - - - - -*/
                    &ENDIF
/* - - - - - - - - - - - - - - - - - - - - - -*/
