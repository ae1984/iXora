/* sr-vrd.p
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

/***************************************************************************\
*****************************************************************************
**  Program: Sr-vrd.p
**       By:
** Descript:
**
*****************************************************************************
\***************************************************************************/

DEFINE INPUT  PARAMETER in-summa  AS DECIMAL.
DEFINE OUTPUT PARAMETER out-summa AS CHARACTER.
DEFINE INPUT  PARAMETER short AS LOG.
DEFINE VARIABLE int-s       AS INTEGER.
DEFINE VARIABLE i           AS INTEGER.
DEFINE VARIABLE j           AS INTEGER.
DEFINE VARIABLE cur-klase   AS INTEGER.
DEFINE VARIABLE klas-s      AS INTEGER.
DEFINE VARIABLE klas-c      AS CHAR.
DEFINE VARIABLE sim-cip     AS INTEGER.
DEFINE VARIABLE vien-cip    AS INTEGER.
DEFINE VARIABLE des-cip     AS INTEGER.
DEFINE VARIABLE klas-dal    AS INTEGER INIT 1000000000.
DEFINE VARIABLE klase       AS CHARACTER EXTENT 12 INIT
  ["миллиард ","миллиарда ","миллиардов ","миллион ","миллиона ",
  "миллионов ","тысяча ","тысячи ","тысяч "," "," "," "].
DEFINE VARIABLE klasd       AS CHARACTER EXTENT 12 INIT
  ["млрд. ","млрд. ","млрд. ","млн. ","млн. ",
  "млн. ","тыс. ","тыс. ","тыс. "," "," "," "].
DEFINE VARIABLE vieni       AS CHARACTER EXTENT 10 INIT
  ["","один ","два ","три ","четыре ","пять ","шесть ",
  "семь ","восемь ","девять "].
DEFINE VARIABLE vient       AS CHARACTER EXTENT 10 INIT
  ["","одна ","две ","три ","четыре ","пять ","шесть ",
  "семь ","восемь ","девять "].
DEFINE VARIABLE desmiti     AS CHARACTER EXTENT 10 INIT
  ["","десять ","двадцать ","тридцать ","сорок ",
  "пятьдесят ",
  "шестьдесят ","семьдесят ","восемьдесят ","девяносто "].
DEFINE VARIABLE padsmiti    AS CHARACTER EXTENT 10 INIT
  ["","одиннадцать ","двенадцать ","тринадцать ",
  "четырнадцать ",
  "пятнадцать ","шестнадцать ","семьнадцать ",
  "восемьнадцать ","девятнадцать "].
DEFINE VARIABLE simti       AS CHARACTER EXTENT 10 INIT
  ["","сто ","двести ","триста ","четыреста ","пятьсот ",
  "шестьсот ","семьсот ","восемьсот ","девятьсот "].
DEFINE VARIABLE mazie  AS CHARACTER EXTENT 8 INIT
  ["о","д","т","ч","п","ш","с","в"].
DEFINE VARIABLE lielie      AS CHARACTER EXTENT 8 INIT
  ["О","Д","Т","Ч","П","Ш","С","В"].

/* int-s = in-summa. */

out-summa = "".
IF klas-s < 0
  THEN.
ELSE
IF in-summa = 0
  THEN
out-summa = "nulle ".
ELSE
DO:
  i = 1.
  /*  REPEAT WHILE i <= 4 AND int-s > 0: */
  /* миллиарды */
  klas-s = INTEGER(SUBSTRING(STRING(in-summa,"999999999999.99"),1,03)).
  klas-c = SUBSTRING(STRING(in-summa,"999999999999.99"),1,03).
  IF klas-s > 0
    THEN
  DO:
    sim-cip = INTEGER(SUBSTRING(klas-c,1,1)).
    des-cip = INTEGER(SUBSTRING(klas-c,2,1)).
    vien-cip = INTEGER(SUBSTRING(klas-c,3,1)).
    out-summa = out-summa + simti[sim-cip + 1].
    j = 3.
    IF des-cip > 1 THEN
    DO:
      out-summa = out-summa + desmiti[des-cip + 1].
      IF vien-cip = 1            THEN
      j = 1.
      ELSE
      IF 1 < vien-cip AND vien-cip <  5    THEN
      j = 2.
      ELSE
      j = 3.
      out-summa = out-summa + vieni[vien-cip + 1].
    END.
    ELSE
    IF des-cip = 1 AND vien-cip > 0 THEN
    out-summa = out-summa + padsmiti[vien-cip + 1].
    ELSE
    IF des-cip = 1 THEN
    out-summa = out-summa + desmiti[des-cip + 1].
    ELSE
    IF  vien-cip > 0 THEN
    DO:
      IF vien-cip = 1         THEN
      j = 1.
      ELSE
      IF 1 < vien-cip AND vien-cip < 5   THEN
      j = 2.
      out-summa = out-summa + vieni[vien-cip + 1].
    END.
    if short then out-summa = out-summa + klasd[3 * (i - 1) + j].
    else out-summa = out-summa + klase[3 * (i - 1) + j].
  END.
  i = i + 1.
  /* END. */
  /* миллионы */
  klas-s = INTEGER(SUBSTRING(STRING(in-summa,"999999999999.99"),4,03)).
  klas-c = SUBSTRING(STRING(in-summa,"999999999999.99"),4,03).
  IF klas-s > 0
    THEN
  DO:
    sim-cip = INTEGER(SUBSTRING(klas-c,1,1)).
    des-cip = INTEGER(SUBSTRING(klas-c,2,1)).
    vien-cip = INTEGER(SUBSTRING(klas-c,3,1)).
    out-summa = out-summa + simti[sim-cip + 1].
    j = 3.
    IF des-cip > 1 THEN
    DO:
      out-summa = out-summa + desmiti[des-cip + 1].
      IF vien-cip = 1            THEN
      j = 1.
      ELSE
      IF 1 < vien-cip AND vien-cip <  5    THEN
      j = 2.
      ELSE
      j = 3.
      out-summa = out-summa + vieni[vien-cip + 1].
    END.
    ELSE
    IF des-cip = 1 AND vien-cip > 0 THEN
    out-summa = out-summa + padsmiti[vien-cip + 1].
    ELSE
    IF des-cip = 1 THEN
    out-summa = out-summa + desmiti[des-cip + 1].
    ELSE
    IF  vien-cip > 0 THEN
    DO:
      IF vien-cip = 1         THEN
      j = 1.
      ELSE
      IF 1 < vien-cip AND vien-cip < 5   THEN
      j = 2.
      out-summa = out-summa + vieni[vien-cip + 1].
    END.
    if short then out-summa = out-summa + klasd[3 * (i - 1) + j].
    else out-summa = out-summa + klase[3 * (i - 1) + j].
  END.
  i = i + 1.
  /* END. */
  /* тысячи  */
  klas-s = INTEGER(SUBSTRING(STRING(in-summa,"999999999999.99"),7,03)).
  klas-c = SUBSTRING(STRING(in-summa,"999999999999.99"),7,03).
  IF klas-s > 0
    THEN
  DO:
    sim-cip = INTEGER(SUBSTRING(klas-c,1,1)).
    des-cip = INTEGER(SUBSTRING(klas-c,2,1)).
    vien-cip = INTEGER(SUBSTRING(klas-c,3,1)).
    out-summa = out-summa + simti[sim-cip + 1].
    j = 3.
    IF des-cip > 1 THEN
    DO:
      out-summa = out-summa + desmiti[des-cip + 1].
      IF vien-cip = 1            THEN
      j = 1.
      ELSE
      IF 1 < vien-cip AND vien-cip <  5    THEN
      j = 2.
      ELSE
      j = 3.
      out-summa = out-summa + vient[vien-cip + 1].
    END.
    ELSE
    IF des-cip = 1 AND vien-cip > 0 THEN
    out-summa = out-summa + padsmiti[vien-cip + 1].
    ELSE
    IF des-cip = 1 THEN
    out-summa = out-summa + desmiti[des-cip + 1].
    ELSE
    IF  vien-cip > 0 THEN
    DO:
      IF vien-cip = 1         THEN
      j = 1.
      ELSE
      IF 1 < vien-cip AND vien-cip < 5   THEN
      j = 2.
      out-summa = out-summa + vient[vien-cip + 1].
    END.
    if short then out-summa = out-summa + klasd[3 * (i - 1) + j].
    else out-summa = out-summa + klase[3 * (i - 1) + j].
  END.
  i = i + 1.
  /* END. */
  /* несчастные числа меньшие тысячи - сотни, десятки, единицы  */
  klas-s = INTEGER(SUBSTRING(STRING(in-summa,"999999999999.99"),10,03)).
  klas-c = SUBSTRING(STRING(in-summa,"999999999999.99"),10,03).
  IF klas-s > 0
    THEN
  DO:
    sim-cip = INTEGER(SUBSTRING(klas-c,1,1)).
    des-cip = INTEGER(SUBSTRING(klas-c,2,1)).
    vien-cip = INTEGER(SUBSTRING(klas-c,3,1)).
    out-summa = out-summa + simti[sim-cip + 1].
    j = 3.
    IF des-cip > 1 THEN
    DO:
      out-summa = out-summa + desmiti[des-cip + 1].
      IF vien-cip = 1            THEN
      j = 1.
      ELSE
      IF 1 < vien-cip AND vien-cip <  5    THEN
      j = 2.
      ELSE
      j = 3.
      out-summa = out-summa + vieni[vien-cip + 1].
    END.
    ELSE
    IF des-cip = 1 AND vien-cip > 0 THEN
    out-summa = out-summa + padsmiti[vien-cip + 1].
    ELSE
    IF des-cip = 1 THEN
    out-summa = out-summa + desmiti[des-cip + 1].
    ELSE
    IF  vien-cip > 0 THEN
    DO:
      IF vien-cip = 1         THEN
      j = 1.
      ELSE
      IF 1 < vien-cip AND vien-cip < 5   THEN
      j = 2.
      out-summa = out-summa + vieni[vien-cip + 1].
    END.
  END.
END.
out-summa = TRIM(out-summa).

/* не работает сравнение для русских букв "c" и "т" и т.д.
if big then do:
i = 1.
def var nnn as char.
nnn = SUBSTRING(out-summa,1,1).
repeat:
  disp nnn i mazie[i].
  pause 55.
  IF mazie[i] EQ nnn THEN LEAVE.
  else i = i + 1.
  disp nnn i mazie[i].
  pause 6336.
END.
disp i mazie[i].
IF i <= 8
THEN
OVERLAY(out-summa,1,1) = lielie[i].
end.                                  */
RETURN.
