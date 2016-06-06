/* CifAddCRMListener.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
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
        --/--/2011
 * BASES
        BANK COMM
 * CHANGES
        08.05.2012 k.gitalov перекомпиляция
*/


{global.i}
{srvcheck.i}
define new shared variable vIsCifExist      as logical   no-undo.
define new shared variable vCif             as character no-undo.
define new shared variable vBin             as character no-undo.
define new shared variable vRegdt           as date      no-undo.
define new shared variable vLnopf           as character no-undo.
define new shared variable vSname           as character no-undo.
define new shared variable vName            as character no-undo.
define new shared variable vRegCert         as character no-undo.
define new shared variable vBdt             as date      no-undo.
define new shared variable vRnnsp           as character no-undo.

define new shared variable vBplace          as character no-undo.
define new shared variable vAddr            as character no-undo.
define new shared variable vAddr2           as character no-undo.

define new shared variable vPss             as character no-undo.
define new shared variable vTel             as character no-undo.
define new shared variable vTlx             as character no-undo.
define new shared variable vFax             as character no-undo.
define new shared variable vStaffQty        as integer   no-undo.
define new shared variable vStatusCif       as character no-undo.
define new shared variable vGeo             as character no-undo.
define new shared variable vEcdivis         as character no-undo. /*сектор экономики*/
define new shared variable vTypeD           as character no-undo. /*тип деятельности*/
define new shared variable vYear_           as decimal   no-undo.
define new shared variable vBank            as character no-undo.
define new shared variable vWeekQty         as integer   no-undo.
define new shared variable vGroup1          as character no-undo.
define new shared variable vGroup2          as character no-undo.
define new shared variable vRating          as character no-undo.
define new shared variable vSecek           as character no-undo.
define new shared variable vRegionKz        as character no-undo.
define new shared variable vStaffId1        as character no-undo.
define new shared variable vStaffId2        as character no-undo.
define new shared variable vCgr             as integer   no-undo.
define new shared variable vBranch          as character no-undo.
define new shared variable vMname           as character no-undo. /*новая категория клиента*/
define new shared variable vClnchf          as character no-undo.
define new shared variable vClnchfdnum      as character no-undo.
define new shared variable vClnchfddt       as date      no-undo.
define new shared variable vClnchfrnn       as character no-undo.
/*новые поля*/
define new shared variable vClnchfd1        as character no-undo.
define new shared variable vClnchfddte      as date      no-undo.
define new shared variable vClnsegm         as character no-undo.
define new shared variable vClnsex          as character no-undo.
define new shared variable vClnsts          as character no-undo.
define new shared variable vPublicf         as character no-undo.
define new shared variable vOwner           as character no-undo.
define new shared variable vJss             as character no-undo.
define new shared variable vSufix           as character no-undo.
define new shared variable vCoregdt         as date      no-undo.
define new shared variable vAttn            as character no-undo.
define new shared variable vClnbk           as character no-undo. /*фио гл.бух*/
define new shared variable vClnbkdt         as date      no-undo. /*дата выдачи уд.л гл.бух*/
define new shared variable vClnbkdtex       as date      no-undo. /*срок действия уд.л гл.бух*/
define new shared variable vClnbknum        as character no-undo. /*номер уд.л гл.бух*/
define new shared variable vClnbkpl         as character no-undo. /*кем выдан*/

define new shared variable vClnokpo         as character no-undo. /*Anuar 27.12.2011 ОКПО */
define new shared variable vClnokpodate     as character no-undo. /*Anuar 27.12.2011 дата ОКПО */

define new shared variable vUpldop          as character no-undo. /*Anuar 28.12.2011 доверенное лицо счет */
define new shared variable vUplcoregdt      as date      no-undo. /*Anuar 28.12.2011 доверенное лицо дата выдачи */
define new shared variable vUplfinday       as date      no-undo. /*Anuar 27.12.2011 доверенное лицо дата окончания */
define new shared variable vUplfio          as character no-undo. /*Anuar 28.12.2011 доверенное лицо ФИО */
define new shared variable vUplpass         as character no-undo. /*Anuar 28.12.2011 доверенное лицо паспорт */

define new shared variable vUplid           as integer   no-undo.

define new shared variable vUplbdt          as date      no-undo. /* Anuar 04.01.2012 доверенное лицо дата рождения */
define new shared variable vUplbplace       as character no-undo. /* Anuar 04.01.2012 доверенное лицо место рождения */
define new shared variable vUpluradr        as character no-undo. /* Anuar 04.01.2012 доверенное лицо юр адрес  */
define new shared variable vUplpasswho      as character no-undo.

/* Anuar 04.01.2012 uchreditel urik */
define new shared variable vUchrurname      as character no-undo.
define new shared variable vUchrurres       as character no-undo.
define new shared variable vUchrurcountry   as character no-undo.
define new shared variable vUchrurorgreg    as character no-undo.
define new shared variable vUchrurnumreg    as character no-undo.
define new shared variable vUchrurdtreg     as character no-undo.
define new shared variable vUchrurbin       as character no-undo.
define new shared variable vUchrurrnn       as character no-undo.
define new shared variable vUchruradress    as character no-undo.
define new shared variable vUchrurtim       as character no-undo.

/* Anuar 05.01.2012 */
define new shared variable vUchrsts         as character no-undo.

define new shared variable vBnkrel          as character no-undo.

/* Anuar 06.01.2012 uchreditel fizik */

define new shared variable vUchrfizsname    as character no-undo.
define new shared variable vUchrfizfname    as character no-undo.
define new shared variable vUchrfizmname    as character no-undo.
define new shared variable vUchrfizres      as character no-undo.
define new shared variable vUchrfizcntr     as character no-undo.
define new shared variable vUchrfizdtbth    as character no-undo.
define new shared variable vUchrfiznumreg   as character no-undo.
define new shared variable vUchrfizpserial  as character no-undo.
define new shared variable vUchrfizorgreg   as character no-undo.
define new shared variable vUchrfizdtreg    as character no-undo.
define new shared variable vUchrfizdtsrokul as character no-undo.
define new shared variable vUchrfizbin      as character no-undo.
define new shared variable vUchrfizrnn      as character no-undo.
define new shared variable vUchrfizadress   as character no-undo.
define new shared variable vUchrfiztim      as character no-undo.

/* Anuar 08.02.2012 */
define new shared variable vIPpassend       as date      no-undo.

define new shared variable vErrorsProgress  as character no-undo.
vErrorsProgress = "".


define new shared variable g-today2 as date no-undo.
g-today2 = g-today.

define variable v-terminate as logical no-undo.
v-terminate = no.

define variable ptpsession   as handle.
define variable consumerH    as handle.
define variable replyMessage as handle.


/******************************************************************/
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.1.22:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.1.12:2507").
/******************************************************************/
run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").


run beginSession in ptpsession.
run createTextMessage in ptpsession (output replyMessage).
run createMessageConsumer in ptpsession (
    this-procedure,
    "requestHandler",
    output consumerH).
run receiveFromQueue in ptpsession ("SQ1",
    ?,
    consumerH).
run startReceiveMessages in ptpsession.
run waitForMessages in ptpsession ("inWait", this-procedure, ?).

procedure requestHandler:
    define input parameter requestH as handle.
    define input parameter msgConsumerH as handle.
    define output parameter replyH as handle.
    define variable replyText    as character.
    define variable msgText      as character.
    define variable vpNames      as character no-undo.
    define variable vMessageGUID as character no-undo.


    msgText = DYNAMIC-FUNCTION('getText':U in requestH).
    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then
    do:
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then
            v-terminate = yes.
    end.
    else
    do:

        vpNames = DYNAMIC-FUNCTION('getPropertyNames':U in requestH).

        if lookup("MessageGUID", vpNames) > 0 then
            vMessageGUID = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "MessageGUID").
        if lookup("Cif", vpNames) > 0 then
            vCif = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Cif").
        if lookup("Bin", vpNames) > 0 then
            vBin = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Bin").
        if lookup("Regdt", vpNames) > 0 then
            vRegdt = date(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Regdt")).
        if lookup("Lnopf", vpNames) > 0 then
            vLnopf = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Lnopf").
        if lookup("Sname", vpNames) > 0 then
            vSname = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Sname").
        if lookup("Name", vpNames) > 0 then
            vName = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Name").
        if lookup("RegCert", vpNames) > 0 then
            vRegCert = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "RegCert").
        if lookup("Bdt", vpNames) > 0 then
            vBdt = date(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Bdt")).
        if lookup("Rnnsp", vpNames) > 0 then
            vRnnsp = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Rnnsp").
        if lookup("Bplace", vpNames) > 0 then
            vBplace = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Bplace").
        if lookup("Addr", vpNames) > 0 then
            vAddr = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Addr").
        if lookup("Addr2", vpNames) > 0 then
            vAddr2 = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Addr2").

        if lookup("Pss", vpNames) > 0 then
            vPss = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Pss").
        if lookup("Tel", vpNames) > 0 then
            vTel = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Tel").
        if lookup("Tlx", vpNames) > 0 then
            vTlx = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Tlx").
        if lookup("Fax", vpNames) > 0 then
            vFax = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Fax").
        if lookup("StaffQty", vpNames) > 0 then
            vStaffQty = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "StaffQty").
        if lookup("StatusCif", vpNames) > 0 then
            vStatusCif = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "StatusCif").
        if lookup("Geo", vpNames) > 0 then
            vGeo = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Geo").
        if lookup("Ecdivis", vpNames) > 0 then
            vEcdivis = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Ecdivis").
        if lookup("TypeD", vpNames) > 0 then
            vTypeD = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "TypeD").
        if lookup("Year_", vpNames) > 0 then
            vYear_ = DYNAMIC-FUNCTION('getDecimalProperty':U in requestH, "Year_").
        if lookup("Bank", vpNames) > 0 then
            vBank = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Bank").
        if lookup("WeekQty", vpNames) > 0 then
            vWeekQty = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "WeekQty").
        if lookup("Group1", vpNames) > 0 then
            vGroup1 = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Group1").
        if lookup("Group2", vpNames) > 0 then
            vGroup2 = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Group2").
        if lookup("Rating", vpNames) > 0 then
            vRating = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Rating").
        if lookup("Secek", vpNames) > 0 then
            vSecek = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Secek").
        if lookup("RegionKz", vpNames) > 0 then
            vRegionKz = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "RegionKz").
        if lookup("StaffId1", vpNames) > 0 then
            vStaffId1 = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "StaffId1").
        if lookup("StaffId2", vpNames) > 0 then
            vStaffId2 = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "StaffId2").
        if lookup("Cgr", vpNames) > 0 then
            vCgr = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Cgr").
        if lookup("Branch", vpNames) > 0 then
            vBranch = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Branch").
        if lookup("Mname", vpNames) > 0 then
            vMname = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Mname").
        if lookup("clnchf", vpNames) > 0 then
            vClnchf = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "clnchf").
        if lookup("clnchfdnum", vpNames) > 0 then
            vClnchfdnum = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "clnchfdnum").
        if lookup("clnchfddt", vpNames) > 0 then
            vClnchfddt = DATE(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "clnchfddt")).
        if lookup("clnchfrnn", vpNames) > 0 then
            vClnchfrnn = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "clnchfrnn").


        if lookup("Owner", vpNames) > 0 then
            vOwner = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Owner").

        if lookup("Jss", vpNames) > 0 then
            vJss = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Jss").



        if lookup("Clnchfd1", vpNames) > 0 then
            vClnchfd1 = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Clnchfd1").

        if lookup("Clnchfddte", vpNames) > 0 then
            vClnchfddte = DATE(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Clnchfddte")).

        if lookup("Clnsegm", vpNames) > 0 then
            vClnsegm = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Clnsegm").

        if lookup("Clnsex", vpNames) > 0 then
            vClnsex = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Clnsex").

        if lookup("Clnsts", vpNames) > 0 then
            vClnsts = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Clnsts").

        if lookup("Publicf", vpNames) > 0 then
            vPublicf = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Publicf").

        if lookup("Sufix", vpNames) > 0 then
            vSufix = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Sufix").

        if lookup("Coregdt", vpNames) > 0 then
            vCoregdt = DATE(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Coregdt")).
        if lookup("Attn", vpNames) > 0 then
            vAttn = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Attn").


        if lookup("Clnbk", vpNames) > 0 then
            vClnbk = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Clnbk").
        if lookup("Clnbkdt", vpNames) > 0 then
            vClnbkdt = DATE(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Clnbkdt")).
        if lookup("Clnbkdtex", vpNames) > 0 then
            vClnbkdtex = DATE(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Clnbkdtex")).
        if lookup("Clnbknum", vpNames) > 0 then
            vClnbknum = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Clnbknum").
        if lookup("Clnbkpl", vpNames) > 0 then
            vClnbkpl = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Clnbkpl").
        /* Anuar 27.12.2011 */
        if lookup("Clnokpo", vpNames) > 0 then
            vClnokpo = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Clnokpo").
        if lookup("Clnokpodate", vpNames) > 0 then
            vClnokpodate = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Clnokpodate").

        /* Anuar 28.12.2011 */
        if lookup("Upldop", vpNames) > 0 then
            vUpldop = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Upldop").
        if lookup("Uplcoregdt", vpNames) > 0 then
            vUplcoregdt = DATE(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uplcoregdt")).
        if lookup("Uplfinday", vpNames) > 0 then
            vUplfinday = DATE(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uplfinday")).
        if lookup("Uplfio", vpNames) > 0 then
            vUplfio = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uplfio").
        if lookup("Uplpass", vpNames) > 0 then
            vUplpass = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uplpass").

        if lookup("Uplbdt", vpNames) > 0 then
            vUplbdt = DATE(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uplbdt")).
        if lookup("Uplbplace", vpNames) > 0 then
            vUplbplace = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uplbplace").
        if lookup("Upluradr", vpNames) > 0 then
            vUpluradr = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Upluradr").
        if lookup("Uplpasswho", vpNames) > 0 then
            vUplpasswho = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uplpasswho").

        /* Anuar 04.01.2012 uchreditel urik  */
        if lookup("Uchrurname", vpNames) > 0 then
            vUchrurname = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrurname").
        if lookup("Uchrurres", vpNames) > 0 then
            vUchrurres = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrurres").
        if lookup("Uchrurcountry", vpNames) > 0 then
            vUchrurcountry = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrurcountry").
        if lookup("Uchrurorgreg", vpNames) > 0 then
            vUchrurorgreg = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrurorgreg").
        if lookup("Uchrurnumreg", vpNames) > 0 then
            vUchrurnumreg = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrurnumreg").
        if lookup("Uchrurdtreg", vpNames) > 0 then
            vUchrurdtreg = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrurdtreg").
        if lookup("Uchrurbin", vpNames) > 0 then
            vUchrurbin = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrurbin").
        if lookup("Uchrurrnn", vpNames) > 0 then
            vUchrurrnn = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrurrnn").
        if lookup("Uchruradress", vpNames) > 0 then
            vUchruradress = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchruradress").
        if lookup("Uchrurtim", vpNames) > 0 then
            vUchrurtim = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrurtim").

        if lookup("Uchrsts", vpNames) > 0 then
            vUchrsts = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrsts").

        if lookup("Uchrsts", vpNames) > 0 then
            vUchrsts = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrsts").

        if lookup("Bnkrel", vpNames) > 0 then
            vBnkrel = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Bnkrel").

        /* Anuar 06.01.2012 */

        if lookup("Uchrfizsname", vpNames) > 0 then
            vUchrfizsname = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizsname").
        if lookup("Uchrfizfname", vpNames) > 0 then
            vUchrfizfname = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizfname").
        if lookup("Uchrfizmname", vpNames) > 0 then
            vUchrfizmname = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizmname").
        if lookup("Uchrfizres", vpNames) > 0 then
            vUchrfizres = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizres").
        if lookup("Uchrfizcntr", vpNames) > 0 then
            vUchrfizcntr = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizcntr").
        if lookup("Uchrfizdtbth", vpNames) > 0 then
            vUchrfizdtbth = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizdtbth").
        if lookup("Uchrfiznumreg", vpNames) > 0 then
            vUchrfiznumreg = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfiznumreg").
        if lookup("Uchrfizpserial", vpNames) > 0 then
            vUchrfizpserial = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizpserial").
        if lookup("Uchrfizorgreg", vpNames) > 0 then
            vUchrfizorgreg = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizorgreg").
        if lookup("Uchrfizdtreg", vpNames) > 0 then
            vUchrfizdtreg = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizdtreg").
        if lookup("Uchrfizdtsrokul", vpNames) > 0 then
            vUchrfizdtsrokul = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizdtsrokul").
        if lookup("Uchrfizbin", vpNames) > 0 then
            vUchrfizbin = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizbin").
        if lookup("Uchrfizrnn", vpNames) > 0 then
            vUchrfizrnn = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizrnn").
        if lookup("Uchrfizadress", vpNames) > 0 then
            vUchrfizadress = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfizadress").
        if lookup("Uchrfiztim", vpNames) > 0 then
            vUchrfiztim = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Uchrfiztim").

        /* Anuar 08.02.2012 */

        if lookup("IPpassend", vpNames) > 0 then
            vIPpassend = DATE(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "IPpassend")).


        /*подключено только к базе петропавл. После теста закоментировать */
        /* vBranch = "TXB10".*/

        if connected ("txb") then  disconnect "txb".
        find first comm.txb where comm.txb.bank = vBranch and comm.txb.consolid no-lock no-error.
        if available comm.txb then
        do:
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
            /*connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -UU " + comm.txb.login + " -P " + comm.txb.login) no-error.*/
            if error-status:error then
                run WriteError.
            if connected ("txb") then
            do:
                run CifAddCRMProc.
                disconnect "txb".
            end.
            else
                vErrorsProgress = vErrorsProgress + "Ошибка подключения к филиалу,".
        end.
        else
        do:
            vErrorsProgress = vErrorsProgress + "Филиал: " + vBranch + " не найден в списке,".
        end.


        run setBooleanProperty in replyMessage ("IsCifExist", vIsCifExist).
        run setStringProperty in replyMessage ("Cif", vCif).
        if vErrorsProgress <> "" then
            run setStringProperty in replyMessage ("ErrorsProgress", SUBSTRING (vErrorsProgress, 1, LENGTH (vErrorsProgress) - 1)).
        else
            run setStringProperty in replyMessage ("ErrorsProgress", vErrorsProgress).

        run setStringProperty in replyMessage ("MessageGUID", vMessageGUID).

        vIsCifExist = false.
        vCif = "".
        vBin = "".
        vRegdt = g-today2.
        vLnopf = "".
        vSname = "".
        vName = "".
        vRegCert = "".
        vBdt = g-today2.
        vRnnsp = "".
        vBplace = "".
        vAddr = "".
        vAddr2 = "".
        vPss = "".
        vTel = "".
        vTlx = "".
        vFax = "".
        vStaffQty = 0.
        vStatusCif = "".
        vGeo = "".
        vEcdivis = "".
        vTypeD = "".
        vYear_ = 0.
        vBank = "".
        vWeekQty = 0.
        vGroup1 = "".
        vGroup2 = "".
        vRating = "".
        vSecek = "".
        vRegionKz = "".
        vStaffId1 = "".
        vStaffId2 = "".
        vCgr = 0.
        vBranch = "".
        vMname = "".
        vClnchf = "".
        vClnchfdnum = "".
        vClnchfddt = g-today2.
        vClnchfrnn = "".
        vOwner = "".
        vJss = "".

        vClnchfd1 = "".
        vClnchfddte = g-today2.
        vClnsegm = "".
        vClnsex = "".
        vClnsts = "".
        vPublicf = "".
        vSufix = "".
        vCoregdt = g-today2.
        vAttn = "".

        vClnbk = "".
        vClnbkdt = g-today2.
        vClnbkdtex = g-today2.
        vClnbknum = "".
        vClnbkpl = "".

        vClnokpo = "".
        vClnokpodate = "".

        vUpldop = "".
        vUplcoregdt = g-today2.
        vUplfinday = g-today2.
        vUplfio = "".
        vUplpass = "".

        vUplid = 0.

        vUplbdt = g-today2.
        vUplbplace = "".
        vUpluradr = "".
        vUplpasswho = "".

        vUchrurname = "".
        vUchrurres = "".
        vUchrurcountry = "".
        vUchrurorgreg = "".
        vUchrurnumreg = "".
        vUchrurdtreg = "".
        vUchrurbin = "".
        vUchrurrnn = "".
        vUchruradress = "".
        vUchrurtim = "".

        vUchrsts = "".

        vBnkrel = "".

        vUchrfizsname = "".
        vUchrfizfname = "".
        vUchrfizmname = "".
        vUchrfizres = "".
        vUchrfizcntr = "".
        vUchrfizdtbth = "".
        vUchrfiznumreg = "".
        vUchrfizpserial = "".
        vUchrfizorgreg = "".
        vUchrfizdtreg = "".
        vUchrfizdtsrokul = "".
        vUchrfizbin = "".
        vUchrfizrnn = "".
        vUchrfizadress = "".
        vUchrfiztim = "".

        vIPpassend = g-today2.

        vErrorsProgress = "".


        run deleteMessage in requestH.
        replyH = replyMessage.
        run setText in replyH (replyText).

    end.
end.

function inWait returns logical.
    return not(v-terminate).
end.


procedure WriteError:
    define variable i as integer no-undo.
    if error-status:error then
    do i = 1 to error-status:num-messages:
        vErrorsProgress = vErrorsProgress + string(error-status:get-message(i)) + ",".
    end.
end procedure.

