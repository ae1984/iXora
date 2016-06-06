/* swiftchk.i
 * MODULE
        Клиентские операции
 * DESCRIPTION
        Проверка загружаемых swift файлов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        15.1.4.1.2, 15.1.4.2.2 , 15.1.4.2.3
 * AUTHOR
        --/--/2013 yerganat
 * BASES
        BANK COMM
 * CHANGES
        18.10.2013 yergant - TZ1750, Дополнительная проверка swift файла
*/

define variable v-32Adate       as char.
define variable v-32Acur        as char.
define variable v-32Aamountstr  as char.
define variable v-32Aamount     as decimal.
define variable v-errorcount    as integer.
define variable v-currentstart  as integer.
define variable v-currentend    as integer.
define variable v-clientstarted as integer.
define variable v-assignstart   as integer.
define variable v-assignend     as integer.
define variable v-assignlinecht as integer.

/***************************************************************************
******     Проверка поле :32A:             *********************************
***************************************************************************/
find first ttmps where ttmps.sstr begins ":32A:"  use-index idx1  no-lock no-error.
if avail ttmps then do:
   v-32Adate = substring(ttmps.sstr, 6, 6).
   date(integer(substring(v-32Adate, 3, 2)) , integer(substring(v-32Adate, 5, 2)) , integer("20" + substring(v-32Adate, 1, 2))) no-error.
   if error-status:error then do:
        put unformatted " ----- Неправильный формат даты в поле :32A:" skip.
        v-errorcount = v-errorcount + 1.
   end.
   v-32Acur = substring(ttmps.sstr, 12, 3).
   if v-32Acur <> 'KZT' then do:
        put unformatted " ----- Валюта должен быть указан KZT в поле :32A:" skip.
        v-errorcount = v-errorcount + 1.
   end.

   v-32Aamountstr = substring(ttmps.sstr, 15).

   if index(v-32Aamountstr, ',') = 0 then do:
        put unformatted " ----- Сумма должен содержать разделитель в поле :32A:" skip.
        v-errorcount = v-errorcount + 1.
   end.
   else do:
       if length(substring(v-32Aamountstr, 1, index(v-32Aamountstr, ',') - 1)) < 1 then do:
            put unformatted " ----- Сумма должен содержать не менее одной цифры до запятой в поле :32A:" skip.
            v-errorcount = v-errorcount + 1.
        end.

        if length(substring(v-32Aamountstr, index(v-32Aamountstr, ',') + 1)) <> 2 then do:
            put unformatted " ----- Сумма должен содержать две цифры после запятой в поле :32A:" skip.
            v-errorcount = v-errorcount + 1.
        end.
    end.

   v-32Aamount = decimal(replace(v-32Aamountstr, ',', '.')) no-error.
   if not error-status:error then do:
        if v-32Aamount > 922337203685477.58 then do:
            put unformatted " ----- Сумма не должен привышать 922337203685477.58 в поле :32A:" skip.
            v-errorcount = v-errorcount + 1.
        end.
   end.
end.
else do:
    put unformatted " ----- Отсутствует поле :32A:" skip.
    v-errorcount = v-errorcount + 1.
end.


/***************************************************************************
******     Проверка поле :50:/D/           *********************************
***************************************************************************/
find first ttmps where ttmps.sstr begins ":50:/D/"  use-index idx1  no-lock no-error.
if avail ttmps then do:
    if length(substring(ttmps.sstr, 8)) <> 20 then do:
       put unformatted " ----- Неверное значение в поле :50:/D/ - длина должна быть 20 символов" skip.
       v-errorcount = v-errorcount + 1.
    end.
    else if chkaaa20(substring(ttmps.sstr, 8)) = no then do:
       put unformatted " ----- Ошибка ключевания счета в поле :50:/D/" skip.
       v-errorcount = v-errorcount + 1.
    end.

    v-currentstart = ttmps.scnt.

    find first ttmps where ttmps.sstr begins ":" and ttmps.scnt > v-currentstart use-index idx1 no-lock no-error.
    if avail ttmps then
        v-currentend = ttmps.scnt.
    else do:
        find last ttmps where ttmps.scnt > v-currentstart  use-index idx1 no-lock no-error.
        v-currentend = ttmps.scnt + 1.
    end.

    find first ttmps where ttmps.sstr begins "/NAME/"  and ttmps.scnt > v-currentstart and  ttmps.scnt < v-currentend  use-index idx1  no-lock no-error.
    if not avail ttmps then do:
        put unformatted " ----- Отсутствует ключ /NAME/ в поле :50:" skip.
        v-errorcount = v-errorcount + 1.
    end.
    else do:
        if length(trim(ttmps.sstr)) < 7 then do:
            put unformatted " ----- Ключ /NAME/ в поле :50: - длина менее 1 символа" skip.
            v-errorcount = v-errorcount + 1.
        end.
        if length(trim(ttmps.sstr)) > 66 then do:
            put unformatted " ----- Ключ /NAME/ в поле :50: - длина более 60 символов" skip.
            v-errorcount = v-errorcount + 1.
        end.
    end.

    find first ttmps where ttmps.sstr begins "/CHIEF/" and ttmps.scnt > v-currentstart and  ttmps.scnt < v-currentend  use-index idx1  no-lock no-error.
    if not avail ttmps then do:
        put unformatted " ----- Отсутствует ключ /CHIEF/ в поле :50:" skip.
        v-errorcount = v-errorcount + 1.
    end.
    else do:
        if length(trim(ttmps.sstr)) < 8 then do:
            put unformatted " ----- Ключ /CHIEF/ в поле :50: - длина менее 1 символа" skip.
            v-errorcount = v-errorcount + 1.
        end.
        if length(trim(ttmps.sstr)) > 67 then do:
            put unformatted " ----- Ключ /CHIEF/ в поле :50: - длина более 60 символа" skip.
            v-errorcount = v-errorcount + 1.
        end.

        if chkFIOsymbols(substring(ttmps.sstr, 8)) = no then do:
            put unformatted " ----- Ключ /CHIEF/ в поле :50: - содержит недопустимые символы" skip.
            v-errorcount = v-errorcount + 1.
        end.
    end.

    find first ttmps where ttmps.sstr begins "/MAINBK/"  and ttmps.scnt > v-currentstart and  ttmps.scnt < v-currentend   use-index idx1  no-lock no-error.
    if not avail ttmps then do:
        put unformatted " ----- Отсутствует ключ /MAINBK/ в поле :50:" skip.
        v-errorcount = v-errorcount + 1.
    end.
    else do:
        if length(trim(ttmps.sstr)) < 9 then do:
            put unformatted " ----- Ключ /MAINBK/ в поле :50: - длина менее 1 символа" skip.
            v-errorcount = v-errorcount + 1.
        end.
        if length(trim(ttmps.sstr)) > 68 then do:
            put unformatted " ----- Ключ /MAINBK/ в поле :50: - длина более 60 символа" skip.
            v-errorcount = v-errorcount + 1.
        end.

        if chkFIOsymbols(substring(ttmps.sstr, 9)) = no then do:
            put unformatted " ----- Ключ /MAINBK/ в поле :50: - содержит недопустимые символы" skip.
            v-errorcount = v-errorcount + 1.
        end.
    end.

    find first ttmps where ttmps.sstr begins "/IRS/"  and ttmps.scnt > v-currentstart and  ttmps.scnt < v-currentend  use-index idx1  no-lock no-error.
    if not avail ttmps then do:
        put unformatted " ----- Отсутствует ключ /IRS/ в поле :50: " skip.
        v-errorcount = v-errorcount + 1.
    end.
    else do:
        if length(trim(ttmps.sstr)) <> 6 then do:
            put unformatted " ----- Ключ /IRS/ в поле :50:  - длина значения должна быть 1 символ" skip.
            v-errorcount = v-errorcount + 1.
        end.
    end.

    find first ttmps where ttmps.sstr begins "/IDN/"  and ttmps.scnt > v-currentstart and  ttmps.scnt < v-currentend  use-index idx1  no-lock no-error.
    if not avail ttmps then do:
        put unformatted " ----- Отсутствует ключ /IDN/ в поле :50:" skip.
        v-errorcount = v-errorcount + 1.
    end.
    else do:
        if chk12_innbin(substring(ttmps.sstr,6)) = no then do:
            put unformatted " ----- Ключ /IDN/ в поле :50: - ошибка ключевания" skip.
            v-errorcount = v-errorcount + 1.
        end.
    end.
end.
else do:
    put unformatted " ----- Отсутствует поле :50:/D/" skip.
    v-errorcount = v-errorcount + 1.
end.



/***************************************************************************
******     Проверка поле :59:  /           *********************************
***************************************************************************/
find first ttmps where ttmps.sstr begins ":59:"  use-index idx1  no-lock no-error.
if avail ttmps then do:
    if length(substring(ttmps.sstr, 5)) <> 20 then do:
       put unformatted " ----- Неверное значение в поле :59: - длина должна быть 20 символов" skip.
       v-errorcount = v-errorcount + 1.
    end.
    else if chkaaa20(substring(ttmps.sstr, 5)) = no then do:
       put unformatted " ----- Ошибка ключевания счета в поле :59:" skip.
       v-errorcount = v-errorcount + 1.
    end.
    v-currentstart = ttmps.scnt.

    find first ttmps where ttmps.sstr begins ":" and ttmps.scnt > v-currentstart use-index idx1  no-lock no-error.
    if avail ttmps then
        v-currentend = ttmps.scnt.
    else do:
        find last ttmps where ttmps.scnt > v-currentstart  use-index idx1 no-lock no-error.
        v-currentend = ttmps.scnt + 1.
    end.

    find first ttmps where ttmps.sstr begins "/NAME/"  and ttmps.scnt > v-currentstart and  ttmps.scnt < v-currentend  use-index idx1  no-lock no-error.
    if not avail ttmps then do:
        put unformatted " ----- Отсутствует ключ /NAME/ в поле :59:" skip.
        v-errorcount = v-errorcount + 1.
    end.
    else do:
        if length(trim(ttmps.sstr)) < 7 then do:
            put unformatted " ----- Ключ /NAME/ в поле :59: - длина менее 1 символа" skip.
            v-errorcount = v-errorcount + 1.
        end.
        if length(trim(ttmps.sstr)) > 66 then do:
            put unformatted " ----- Ключ /NAME/ в поле :59: - длина более 60 символов" skip.
            v-errorcount = v-errorcount + 1.
        end.
    end.

    find first ttmps where ttmps.sstr begins "/IDN/"  and ttmps.scnt > v-currentstart and  ttmps.scnt < v-currentend  use-index idx1  no-lock no-error.
    if not avail ttmps then do:
        put unformatted " ----- Отсутствует ключ /IDN/ в поле :59:" skip.
        v-errorcount = v-errorcount + 1.
    end.
    else do:
        if chk12_innbin(substring(ttmps.sstr,6)) = no then do:
            put unformatted " ----- Ключ /IDN/ в поле :59: - ошибка ключевания" skip.
            v-errorcount = v-errorcount + 1.
        end.
    end.
end.
else do:
    put unformatted " ----- Отсутствует поле :59:" skip.
    v-errorcount = v-errorcount + 1.
end.


/***************************************************************************
******     Проверка поле :70: в последовательности A  **********************
***************************************************************************/
v-clientstarted = 0.
find first ttmps where ttmps.sstr begins ":21:" use-index idx1  no-lock no-error.
if avail ttmps then
    v-clientstarted = ttmps.scnt.

if v-clientstarted = 0 then
    find first ttmps where ttmps.sstr begins ":70:" use-index idx1  no-lock no-error.
else
    find first ttmps where ttmps.sstr begins ":70:" and ttmps.scnt < v-clientstarted  use-index idx1 no-lock no-error.

if avail ttmps then do:
    v-currentstart = ttmps.scnt.

    find first ttmps where ttmps.sstr begins ":" and ttmps.scnt > v-currentstart  use-index idx1 no-lock no-error.
    if avail ttmps then
        v-currentend = ttmps.scnt.
    else do:
        find last ttmps where ttmps.scnt > v-currentstart use-index idx1  no-lock no-error.
        v-currentend = ttmps.scnt + 1.
    end.


    find first ttmps where ttmps.sstr begins "/ASSIGN/" and ttmps.scnt > v-currentstart and ttmps.scnt < v-currentend use-index idx1  no-lock no-error.
    if not avail ttmps then do:
        put unformatted " ----- Отсутствует ключ /ASSIGN/ в поле :70:" skip.
        v-errorcount = v-errorcount + 1.
    end.
    else do:
        v-assignstart = ttmps.scnt.
        find first ttmps where ( ttmps.sstr begins "/" or ttmps.sstr begins ":" ) and ttmps.scnt > v-assignstart use-index idx1  no-lock no-error.
        if avail ttmps then
            v-assignend = ttmps.scnt.
        else do:
            find last ttmps where ttmps.scnt > v-assignstart use-index idx1  no-lock no-error.
            v-assignend = ttmps.scnt + 1.
        end.
        v-assignlinecht = 0.
        for each ttmps where ttmps.scnt >= v-assignstart and ttmps.scnt < v-assignend  no-lock:
            if length(ttmps.sstr) > 70 then do:
                put unformatted " ----- Ключ /ASSIGN/ в поле :70: - длина более 70 символов. Строка ".
                put unformatted ttmps.scnt skip.
                v-errorcount = v-errorcount + 1.
            end.
            v-assignlinecht = v-assignlinecht + 1.
        end.
        if v-assignlinecht > 7 then do:
            put unformatted " ----- Ключ /ASSIGN/ в поле :70: - более 7 строк" skip.
            v-errorcount = v-errorcount + 1.
        end.
    end.
end.
else do:
    put unformatted " ----- Отсутствует поле :70:" skip.
    v-errorcount = v-errorcount + 1.
end.


/***************************************************************************
******     THE END                                    **********************
***************************************************************************/
v-errnmb = v-errnmb + v-errorcount.
v-errcnt = v-errcnt + v-errorcount.


