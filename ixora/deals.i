/* deals.i
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
        28.05.2013 damir - Внедрено Т.З. № 1541.
        17.07.2013 damir - Внедрено Т.З. № 1523.
*/

DEFINE {1} TEMP-TABLE deals {2}
    FIELD account AS CHARACTER FORMAT "x(16)" LABEL "Account"
    FIELD amount AS DECIMAL DECIMALS 2 FORMAT "->>,>>>,>>>,>>>,>>9.99" LABEL "Amount"
    FIELD crc AS INTEGER FORMAT ">9" INITIAL 1 LABEL "CURRENCY"
    FIELD dc AS CHARACTER FORMAT "x(1)" LABEL "Debit/Credit"
    FIELD trxtrn AS CHARACTER FORMAT "x(20)" LABEL "CustTrn"
    FIELD dealtrn AS CHARACTER FORMAT "x(20)" LABEL "CustTrn"
    FIELD custtrn AS CHARACTER FORMAT "x(20)" LABEL "CustTrn"
    FIELD ordins AS CHARACTER FORMAT "x(50)" LABEL "OrdIns"
    FIELD ordcust AS CHARACTER FORMAT "x(50)" LABEL "OrdCust"
    FIELD ordacc AS CHARACTER FORMAT "x(50)" LABEL "OrdAcc"
    FIELD benfsr AS CHARACTER FORMAT "x(50)" LABEL "BenFsr"
    FIELD benacc AS CHARACTER FORMAT "x(50)" LABEL "BenAcc"
    FIELD benbank AS CHARACTER FORMAT "x(50)" LABEL "BenBank"
    FIELD dealsdet AS CHARACTER FORMAT "x(50)" LABEL "DealsDet"
    FIELD bankinfo AS CHARACTER FORMAT "x(50)" LABEL "BankInfo"
    FIELD d_date AS DATE LABEL "Date"
    FIELD servcode AS CHARACTER LABEL "ServCode"
    FIELD trxcode AS CHARACTER LABEL "TRXCode"
    FIELD who AS CHARACTER LABEL "Officer"
    FIELD in_value AS INTEGER   FORMAT ">9" LABEL "INTEGER"
    FIELD cif AS CHARACTER
    FIELD print AS CHARACTER
    FIELD ln AS INTEGER
    FIELD ref AS CHARACTER
    FIELD inbal as DECIMAL
    FIELD outbal as DECIMAL
    INDEX acdsrv_idx IS PRIMARY account ASCENDING
                              servcode ASCENDING
                              d_date ASCENDING
    index idx1 account ascending
             servcode ascending
             d_date ascending
             who ascending
    index idx2 account ascending
             servcode ascending
    index idx3 account ascending
             servcode ascending
             d_date ascending
    index idx4 account ascending
             servcode ascending
             d_date ascending
             dc ascending
    index idx5 cif ascending
    index idx6 cif ascending
             account ascending
             d_date ascending
    index idx7 cif ascending
               account ascending.

