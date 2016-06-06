/* html_stuff.i
 * MODULE
        Разный HTML stuff
 * DESCRIPTION
        Полезные HTML функции
 * RUN
 * CALLER
 * SCRIPT
 * INHERIT
 * MENU
 * AUTHOR
        27/01/04 isaev
 * CHANGES
        23.04.04 isaev добавил новый css класс
 */

&global-define HTMLOUT stream html_stream
&global-define HTML put {&HTMLOUT} unformatted

def stream html_stream.
def var html_file as char init "html_stream.html".
def var html_started as logical init no.

def var koi8r as char case-sensitive initial "А,Б,В,Г,Д,Е,Ё,Ж,З,И,Й,К,Л,М,Н,О,П,Р,С,Т,У,Ф,Х,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я,а,б,в,г,д,е,ё,ж,з,и,й,к,л,м,н,о,п,р,с,т,у,ф,х,ц,ч,ш,щ,ъ,ы,ь,э,ю,я".
def var cp1251 as char case-sensitive initial "ю,а,б,ц,д,е,Ё,ф,г,х,и,й,к,л,м,н,о,п,я,р,с,т,у,ж,в,ь,ы,з,ш,э,щ,ч,ъ,Ю,А,Б,Ц,Д,Е,ё,Ф,Г,Х,И,Й,К,Л,М,Н,О,П,Я,Р,С,Т,У,Ж,В,Ь,Ы,З,Ш,Э,Щ,Ч,Ъ,".
def var crlf as char initial "~r~n" format "xx".


/*
 * Заменяет спец HTML символы в строке на их эквивалент в HTML кодах.
 * @param str исходная строка
 * @returns измененную строку
 */
function html_specialchars returns char (str as char):
    return replace(replace(str, ">", "&gt;"), "<", "&lt;").
end.


/*
 * Возвращает строку в которой все символы CR имзенены на HTML <BR>.
 * @param str исходная строка
 * @returns измененную строку
 */
function html_nl2br returns char (str as char):
    return replace(replace(str, "~r", ""), "~n", "<br/>" + crlf).
end.


/*
 * Вывод HTML header
 * @param html_title заголовок в теге <TITLE></TITLE>
 */
function html_header returns char (html_title as char):
    return
        "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.0 Transitional//EN"">" + crlf +
        "<html>" + crlf +
        "<head>" + crlf +
        "<title>" + html_specialchars(html_title) + "</title>" + crlf +
        "<style>" + crlf +
        "  BODY, TD, TH, INPUT, SELECT, OPTION, TEXTAREA \{" + crlf +
        "   font-family: Verdana, Arial, sans-serif;" + crlf +
        "   font-size: xx-small;" + crlf +
        "  \}" + crlf +

        "  A, A:visited, A:active \{" + crlf +
        "   text-decoration: none;" + crlf +
        "   color: #333333;" + crlf +
        "  \}" + crlf +
        
        "  A:hover \{" + crlf +
        "   text-decoration: underline;" + crlf +
        "   color: #FF0000;" + crlf +
        "  \}" + crlf +
        
        "  TABLE \{" + crlf +
        "   background-color: #000000;" + crlf +
        "  \}" + crlf +

        /* TABLE HEADER */
        "  TD.hdr \{" + crlf +
        "   background-color: #DDDDDD;" + crlf +
        "   text-align: center;" + crlf +
        "   font-weight: bold;" + crlf +
        "  \}" + crlf +

        /* TABLE FOOTER */
        "  TD.ftr \{" + crlf +
        "   background-color: #777777;" + crlf +
        "   color: #FFFFFF;" + crlf +
        "   font-weight: bold;" + crlf +    
        "  \}" + crlf +

        /* STADDART CELL */
        "  TD \{" + crlf +
        "   background-color: #FFFFFF;" + crlf +
        "  \}" + crlf +

        /* HIGHILIT ALT 1*/
        "  TD.hl1 \{" + crlf +
        "   background-color: #F7F7F7;" + crlf +
        "   font-weight: bold;" + crlf +
        "  \}" + crlf +

        /* HIGHILIT ALT 2*/
        "  TD.hl2 \{" + crlf +
        "   background-color: #EEEEEE;" + crlf +
        "  \}" + crlf +

        /* HIGHILIT ALT 3*/
        "  TD.hl3 \{" + crlf +
        "   background-color: #FFf4f4;" + crlf +
        "  \}" + crlf +

        "  PRE \{" + crlf +
        "   font-size: x-small;" + crlf +
        "  \}" + crlf +

        "  .sm1 \{" + crlf +
        "   color: #AAAAAA;" + crlf +
        "  \}" + crlf +

        "  .hh1 \{" + crlf +
        "   font-weight: bold;" + crlf +
        "   font-size: x-small;" + crlf +
        "  \}" + crlf +

        "  .hh2 \{" + crlf +
        "   font-weight: bold;" + crlf +
        "  \}" + crlf +

        "  .hh3 \{" + crlf +
        "   font-size: x-small;" + crlf +
        "  \}" + crlf +

        "</style>" + crlf +
        "</head>" + crlf +
        "<body topmargin=20 rightmargin=20 bottommargin=20 leftmargin=20 marginheight=20 marginwidth=20 link=#0000FF vlink=#0000FF bgcolor=#FFFFFF>" + crlf +
        "<a name=""top""></a>" + crlf +
        "<table width=640 cellpadding=0 border=0 cellspacing=0 border=0>" + crlf +
        "<tr>" + crlf +
        "<td><a href=""http://www.texakabank.kz""><img src=""http://portal/img/logo.gif"" border=0 alt=""TEXAKABANK"" width=136 height=25></a></td>" + crlf +
        "</tr>" + crlf +
        "</table>" + crlf +
        "<br><br>" + crlf.
end.



/*
 * Вывод HTML footer
 */
function html_footer returns char:
    return 
        "<br><br>" + crlf +
        "<table width=640 cellpadding=0 border=0 cellspacing=0 border=0>" + crlf +
        "<tr><td><hr size=1 noshade></td></tr>" + crlf +
        "<tr><td class=sm1>Все права защищены &copy; 2000-2004 TEXAKABANK</td></tr>" + crlf +
        "</table><br><br>" + crlf +
        "</body>" + crlf +
        "</html>" + crlf.
end.


/*
 * Конвертирует строку из KOI-8r в CP-1251
 * @param inp исходеная строка в KOI-8r
 * @returns строку в виде CP-1251
 */
function koi2cp returns char(inp as char):
    def var i as int.
    def var id as int.
    def var symb as char.
    def var ret as char initial "".
    do i = 1 to length(inp):
        symb = substring(inp, i, 1).
        id = lookup(symb, koi8r, ",").
        if id > 0 then
            ret = ret + entry(id, cp1251, ",").
        else
            ret = ret + symb.
    end.
    return ret.
end.

/*
 * Конвертирует строку из CP-1251 в KOI-8r
 * @param inp исходеная строка в CP-1251
 * @returns строку в виде KOI-8r
 */
function cp2koi returns char(inp as char):
    def var i as int.
    def var id as int.
    def var symb as char.
    def var ret as char initial "".
    do i = 1 to length(inp):
        symb = substring(inp, i, 1).
        id = lookup(symb, cp1251, ",").
        if id > 0 then
            ret = ret + entry(id, koi8r, ",").
        else
            ret = ret + symb.
    end.
    return ret.
end.



/*
 * Возвращает тег <TABLE>
 * @param pad - CELLPADDING
 * @param spac - CELLSPACING
 * @param width - WIDTH
 * @returns сформированный тег
 */
function html_table returns char (pad as int, spac as int, wdth as char):
    return "<table cellpadding=" + string(pad) + " cellspacing=" + string(spac) + " width=" + wdth + ">".
end.

/*
 * Возвращает тег </TABLE>
 * @returns сформированный тег
 */
function html_elbat returns char ():
    return "</table>".
end.


/*
 * Начинает новый HTML файл
 * @param title значени тега <TITLE>
 */
procedure start_html:
    def input param titl as char.

    if html_started then do:
        message "Ошибка: Попытка повторного вызова start_html без закрывающего finish_html".
        return.
    end.

    output {&HTMLOUT} to value(html_file).
    {&HTML} html_header(titl) crlf.

    html_started = yes.
end.

/*
 * Заканчивает HTML файл и передает его клиенту в iexplorer.exe
 */
procedure finish_html:
    if not html_started then do:
        message "Ошибка: вызов finish_html без предшевствующего вызова start_html".
        return.
    end.

    {&HTML} html_footer() crlf.
    output {&HTMLOUT} close.
    unix silent value("cptwin " + html_file + " explorer").
    unix silent value("rm -f " + html_file).
    html_started = no.
end.
