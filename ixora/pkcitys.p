/* edcntry.p
 * MODULE
      ПОтреб кредиты 
 * DESCRIPTION
        Редактирование справочника городов
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        07.05.07 marinav 
 * CHANGES
*/

{mainhead.i}
{comm-txb.i}
{pkcitys.f}

def var v-title as char.
def var v-codif as char init "iso3166".
def var v-bank as char.
def var v-centrofis as logical.
def var v-ans as logical.
def var v-vidsort as char.

define variable s_rowid as rowid.

v-bank = comm-txb ().

v-centrofis = (v-bank = "TXB00").

v-title = "КОДЫ СТРАН ДЛЯ КРЕДИТНОГО БЮРО".



{jabrw.i 
&start     = "displ v-title format 'x(50)' at 15 with row 4 no-box no-label frame f-header."
&head      = "codfr"
&headkey   = "code"
&index     = "main"

&formname  = "pkcitys"
&framename = "f-ed"
&where     = " codfr.codfr = 'pkcity0' and codfr.code <> 'msc'  "

&addcon    = " true "
&deletecon = " true "
&postcreate = " codfr.codfr = 'pkcity0'. "
&prechoose = "displ '<F4>- выход, <INS>- вставка, <F10>- удалить' 
  with centered row 22 no-box frame f-footer."

&postdisplay = " "
&display   = " codfr.code codfr.name[1] codfr.name[2] "
&highlight = " codfr.code  "
&update   = " codfr.code codfr.name[1] codfr.name[2]  "
&postupdate = " "

&postkey   = "   "

&end = "hide frame f-ed. hide frame f-header. hide frame f-footer."
}
hide message.


