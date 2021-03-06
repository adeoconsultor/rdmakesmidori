#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "FONT.ch"

#define STR0001  "OP's Previstas"
#define STR0002  "Firma OPs"
#define STR0003  "Exclui OPs"
#define STR0004  " Firma as OPs marcadas ?"
#define STR0005  " Deleta as OPs marcadas ?"
#define STR0006  "Selecionando Registros..."
#define STR0007  "Pesquisar"
#define STR0008  "Aten��o"
#define STR0009  "Todas as OPs intermedi�rias que possuam vinculo com alguma OP Pai marcada no Browse, ser�o firmadas, "
#define STR0010  "devido o sistema estar parametrizado para trabalhar com produ��o autom�tica (MV_PRODAUT habilitado). "
#define STR0011  "Deseja continuar o processo ?"
#define STR0012  "Sim"
#define STR0013  "N�o"
#define STR0014  "Deletando OP's previstas..."
#define STR0015  "Deletando SC's previstas..."
#define STR0016  "Deletando PC's/CP's previstos..."

//---------------------------------
/*
Este Programa controla o embarque dos planos produzidos
*/
User Function MD_PLANEMB()



Local	nI			:= 0
Local 	aCampos		:= {}
Private cMarca 		:= GetMark()

//
//����������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa  �
//� ----------- Elementos contidos por dimensao ------------ �
//� 1. Nome a aparecer no cabecalho                          �
//� 2. Nome da Rotina associada                              �
//� 3. Usado pela rotina                                     �
//� 4. Tipo de Transa��o a ser efetuada                      �
//�    1 - Pesquisa e Posiciona em um Banco de Dados         �
//�    2 - Simplesmente Mostra os Campos                     �
//�    3 - Inclui registros no Bancos de Dados               �
//�    4 - Altera o registro corrente                        �
//�    5 - Remove o registro corrente do Banco de Dados      �
//�    6 - Altera determinados campos sem incluir novos Regs �
//������������������������������������������������������������

//����������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes               �
//������������������������������������������������������������
Private cCadastro := "Planos Embarcados..."

Private aRotina := MenuDef()
Private aIndTmp 	:= {}
Private aSavMTA652  := Array(8)
Private oVermelho   := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oAmarelo    := LoadBitmap( GetResources(), "BR_AMARELO" )
Private oVerde      := LoadBitmap( GetResources(), "BR_VERDE" )

//��������������������������������������������������������������Ŀ
//� Definicao de variaveis para rotina de inclusao automatica



//����������������������������������������������������������������


//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01            // De  Produto                           �
//� mv_par02            // Ate Produto                           �
//� mv_par03            // De  Ordem de Producao                 �
//� mv_par04            // Ate Ordem de Producao                 �
//� mv_par05            // De  Data de Entrega                   �
//� mv_par06            // Ate Data de Entrega                   �
//� mv_par07            // De  Data de Inicio                    �
//� mv_par08            // Ate Data de Inicio                    �
//����������������������������������������������������������������

Pergunte("MTA652",.F.)
For ni := 1 to 8
	aSavMTA652[ni] := &("mv_par"+StrZero(ni,2))
Next ni

dbSelectArea("SZG")
//����������������������������������������������������������Ŀ
//� Filtra o arquivo conforme perguntas antes de mostrar     �
//� o browse                                                 �
//������������������������������������������������������������
PLNPFiltEmb(5)
dbGoTop()
// MarkBrow("SC2","C2_OK",  ,  ,   , cMarca)
//
aCampos := {}
AADD(aCampos,{"ZG_OK"            		,""," "})
AADD(aCampos,{"ZG_PLANO"    		    ,"","Num. Plano "    })
AADD(aCampos,{"ZG_NUMEMB"    		    ,"","Num. Embarc"    })
AADD(aCampos,{"ZG_SEQUEN"  	    	    ,"","Sequencia "    })
AADD(aCampos,{"ZG_QTDEPLA"  	        ,"","Qtde Plano"    })
AADD(aCampos,{"ZG_DATA"    	         	,"","Data Lanc"    })
AADD(aCampos,{"ZG_DTEMBAR"    		    ,"","Data Embarq" ,   })
AADD(aCampos,{"ZG_INVOICE"    			,"","Invoice"    })
AADD(aCampos,{"ZG_QTDEEMB"    	        ,"","Qtde Emb"    })
//
aCores := {} // Limpando a variavel
Aadd(aCores,{" ZG_QTDISPE == ZG_QTDEEMB .and. ZG_EMBARCA == 'S' "                     ,"BR_VERMELHO" })
Aadd(aCores,{" ZG_QTDISPE <> ZG_QTDEEMB .and. ZG_EMBARCA == 'S' "                     ,"BR_AMARELO"  })
Aadd(aCores,{" ZG_EMBARCA == 'N' .or. ZG_EMBARCA == '' .or. ZG_EMBARCA == ' ' "       ,"BR_VERDE"    })
//Aadd(aCores,{"(empty(C2_EMBARC) .or. C2_EMBARC =='N') .AND. C2_LIBER  == 'OK' "    ,"BR_VERDE" })

//
MarkBrow("SZG","ZG_OK", ,aCampos , , cMarca , , , , , , , , , aCores )
//
//��������������������������������������������������������������Ŀ
//� Retorna indices do SC2                                       �
//����������������������������������������������������������������
RetIndex("SZG")
dbSetOrder( 5 ) // Ordenado pelo numero do Plano do Cliente
aEval(aIndTmp, {|cFile| fErase(cFile+OrdBagExt())})


RETURN
//----------------------------------
Static FUNCTION PLNPFiltEmb(nOrder)
LOCAL cIndice,nInd,cFirmaCond:=""
Local cNomeInd:=CriaTrab(NIL,.F.)
nOrder := If(nOrder=Nil,5,nOrder)

Aadd(aIndTmp, cNomeInd)
//��������������������������������������������������������������Ŀ
//� Gera index de trabalho do SC2                                �
//����������������������������������������������������������������
dbSelectArea("SZG")
dbSetOrder( 5 )
cIndice   := Indexkey()
//cFirmaCond := 'ZG_FILIAL=="'+xFilial("SZG") //+'".And. '
//cFirmaCond += ' ! Empty( C2_OPMIDO ) .And. C2_EMBARC  == "T" '

IndRegua("SZG",cNomeInd,cIndice,,cFirmaCond,"Selecionando REGISTROS...")	//"Selecionando Registros..."

nInd := RetIndex("SZG")
dbSetOrder(nInd+1)
Return
//--------------------------------------------
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �LPLNPesqPla� Autor � Marcelo Iuspa         � Data � 24/09/01 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Botao Pesquisa do aRotina                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata651                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function VPesqPlan
Local cCampo,nReg
Local nOpt1:=nOrdemAtual
Local cOrd
Local oDlg, nOpca := 0
Private aOrd := {}
PesqOrd("SZG")
cCampo  := Space(40)
aEval(aOrd, {|x, y| aOrd[y] := OemToAnsi(x)})
cOrd := aOrd[nOrdemAtual]

DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 50 TITLE OemToAnsi(STR0007) //"Pesquisar"
@ 0.6,1.3 COMBOBOX oCBX VAR cOrd ITEMS aOrd  SIZE 165,44  ON CHANGE (nOpt1:=oCbx:nAt)  OF oDlg FONT oDlg:oFont
@ 2.1,1.3 MSGET cCampo SIZE 165,10
DEFINE SBUTTON FROM 055,122   TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 055,149.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED
If nOpca == 0
	Return 0
Endif
dbSetOrder(nOpt1)
nOrdemAtual := IndexOrd()
PLNPFiltra(nOrdemAtual)
nReg := RecNo()
If ! dbSeek(xFilial("SZG")+trim(cCampo), .T.)
	dbGoTo(nReg)
	Help(" ",1,"PESQ01")
EndIF
Return .T.
//-----------------------------
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �08/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()


Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             {"Visualizar","U_VVISUPLA",0,2} ,;
             {"Incluir","U_AINCLUI",0,3} ,;  
             {"&Visual. Embarq","U_VisuEMB",0,4} ,;
			 {"Alterar Embarq","U_vAltEMB",0,4} ,;             
             {"Excluir Embarq","U_vExcEMB",0,5} ,;
             {"Legenda","u_vLegStat",0,0} }




Return(aRotina)
//------------------------------------------------------------------------------------------------
USER FUNCTION VVISUPLA()
A650VIEW( 'SZG', SZG->( RECNO() ), 2 )
Return()



User Function VisuEmb(cAlias,nReg,nOpc)
Local aSaveArea := GetArea()
Local aCampos := {}
Local aAltera := {}
Local nOpca := 0
Local cArq 
Local aTpSald := ""
Local lEmbarque
Local oGetDb
Local oDlg
Local oFnt                
Local oEmbarque    
Private lImpresso     := .F.
Private aTela := {}
Private aGets := {}
Private aHeader := {}
Public cInvoice := ""                              

aCampos := U_VaHeader(@aAltera)


//+----------------------------------------------------------------+
//| Cria arquivo Temporario para uso com MSGETDB |

U_vCriaTMP(aCampos,@cArq)

//+----------------------------------------------------------------+
//| Carrega dados para MSGETDB |
//+----------------------------------------------------------------+
//cNumEmb := U_EmbCarr(4)
cNumEmb   := SZG->ZG_NUMEMB

dbSelectArea("SZG")
dbSetOrder(5)
if dbSeek(xFilial("SZG")+cNumEmb)

	cInvoice := SZG->ZG_INVOICE
	U_VEmbCarr(cNumEmb, 2)

	DEFINE MSDIALOG oDlg TITLE cCadastro From 8,0 To 40,120 OF oMainWnd

  	DEFINE FONT oFnt	NAME "Arial" Size 10,15
  	DEFINE FONT oFntCabec NAME "Arial" Size 10, 30
		oTPanel1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,20,.T.,.F.)
		oTPanel1:Align := CONTROL_ALIGN_TOP

	
		@ 4, 005 SAY "EMBARQUE: " PIXEL FONT oFntCabec COLOR CLR_BLUE OF oTPanel1


		@ 4, 070 SAY cNumEmb PIXEL FONT oFntCabec COLOR CLR_BLACK OF oTPanel1
		@ 4, 160 SAY "INVOICE " PIXEL FONT oFntCabec COLOR CLR_BLUE of oTPanel1
		@ 4, 240 MSGET cInvoice   When .F. SIZE 78,7 PIXEL OF oTPanel1
		oTPanel2 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,24,.T.,.F.)
		oTPanel2:Align := CONTROL_ALIGN_BOTTOM
		If nOpc == 4                                                                                                     
  		oGetDB  := MSGetDB():New(0, 0, 0, 0, Iif(nOpc==3,4,nOpc),"U_vcLok","U_vcTOk", "+ZG_SEQUEN",.t.,aAltera,,.t.,,"TMP",,,,,,,) //"U_cDel")
		Else
		   oGetDB := MSGetDados():New(0,0,0,0,nOpc)
		Endif

		oGetDB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
//  	@225,420  BMPBUTTON TYPE 06 ACTION (ExecBlock("U_cTOk(cInvoice)"), ExecBlock("MD_RELEMBPL(cNumEmb)") ) 
	  	@225,420  BMPBUTTON TYPE 06 ACTION if(u_cTok(cNumEmb), U_MD_RELEMBPL(cNumEmb), Alert("Acerte as informacoes antes de imprimir..."))

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||nOpca:=1, oDlg:End(),nOpca := 0},	{||nOpca:=2, oDlg:End()}) VALID nOpca != 0 CENTERED
	
else
	Alert("N�o H� Planos a serem embarcados e/ou os planos marcados j� embarcaram...")
endif
DbSelectArea( "TMP" )
DbCloseArea()
If Select("cArq") = 0
	FErase(cArq+GetDBExtension())
EndIf	
	
dbSelectArea("SZG")
dbSetOrder(1)


	
Return nOpca


/*
//+------------+---------+-------+-----------------------+------+----------+
| Funcao |cTOk| Autor | Pilar S. Albaladejo | Data | 24/07/00 |
+------------+---------+-------+-----------------------+------+----------+
| Descricao | Valida MSGETDB -> Tudo OK |
+------------+-----------------------------------------------------------+
| Sintaxe | cTOk(ExpC1) |
+------------+-----------------------------------------------------------+
| Parametros | Nenhum |
+------------+-----------------------------------------------------------+
| Retorno | Nenhum |
+------------+-----------------------------------------------------------+
| Uso | CTBA120 |
+------------+-----------------------------------------------------------+
/*/
user function vcTOk(cNumEmb)
Local aSaveArea := GetArea()
Local lRet := .T.
Local cMsg := ""
dbSelectArea("TMP")
dbGotop()
	while !TMP->(eof()) 
		if lRet             
			if !TMP->ZG_FLAG
				if cInvoice = space(20)
					Alert("Informar numero da invoice")
					lRet:=.F.
				endif
				if TMP->ZG_QTDEEMB > TMP->ZG_QTDISPE
					Alert("Quantidade a embarcar nao pode ser maior que a quantidade diponivel para embarque")
					lRet := .F.
				endif 
				if TMP->ZG_QTDEEMB < 0 
					Alert("Quantidade a embarcar nao pode ser negativo")
					lRet := .F.        
				endif
			endif    
		endif
		TMP->(dbSkip())		
	enddo
//if lRet                                           
//	u_GravaEmb(cNumEmb,4,cInvoice, lEmbarque)	
//endif
	
RestArea(aSaveArea)
Return lRet




user Function vcLOk()
Local lRet := .T.
Local nCont
	if TMP->ZG_QTDEEMB > TMP->ZG_QTDISPE
		Alert("Quantidade a embarcar nao pode ser maior que a quantidade diponivel para embarque")
		lRet := .F.
	endif

Return lRet


/*/
+------------+---------+-------+-----------------------+------+----------+
| Funcao |CriaTMP| Autor | Pilar S. Albaladejo | Data | 24/07/00 |
+------------+---------+-------+-----------------------+------+----------+
| Descricao | Cria Arquivo Temporario para MSGETDB |
+------------+-----------------------------------------------------------+
| Sintaxe | CriaTMP(ExpA1,ExpC1) |
+------------+-----------------------------------------------------------+
| Parametros | ExpA1 = Matriz com campos a serem criados |
| | ExpC1 = Nome do arquivo temporario |
+------------+-----------------------------------------------------------+
| Retorno | Nenhum |
+------------+-----------------------------------------------------------+
| Uso | CTBA120 |
+------------+-----------------------------------------------------------+
/*/
user Function vCriaTMP(aCampos,cArq)
Local cChave
Local aSaveArea := GetArea()
cChave := ""
cArq := CriaTrab(aCampos,.t.)
dbUseArea(.t.,,cArq,"TMP",.t.,.f.)
RestArea(aSaveArea)

Return



user Function VaHeader(aAltera)
Local aSaveArea:= GetArea()
Local aFora := {} //{"ZG_EMBARCA","ZG_NUMEMB"}
Local aCampos := {}
Local nCriter := 0
PRIVATE nUsado := 0

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SZG")
While !EOF() .And. (x3_arquivo == "SZG")
	If Alltrim(x3_campo) == "SZG_SEQUEN" .Or. ;
			x3Uso(x3_usado) .and. cNivel >= x3_nivel
		If Ascan(aFora,Trim(X3_CAMPO)) <= 0
			nUsado++
			AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, "TMP", x3_context } )
			If Alltrim(x3_campo) <> "ZG_SEQUEN"
				Aadd(aAltera,Trim(X3_CAMPO))               
			EndIf
		EndIF
	EndIF                                                                            
	aAdd( aCampos, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL } )
	dbSkip()
EndDO
Aadd(aCampos,{"ZG_FLAG","L",1,0})
RestArea(aSaveArea)

Return aCampos



user Function VEmbCarr(cNumEmb, nOpc)
Local aSaveArea:= GetArea()
Local cAlias := "SZG"
Local nPos 
Local nCont      
nOpc := 2
//Alert("Entrando para carregar os planos....")
If nOpc != 3 // Visualizacao / Alteracao / Exclusao
//	cNumEmb := U_Planos()
//	Alert("Embarque numero: "+cNumEmb)	
	dbSelectArea("SZG")
	dbSetOrder(5)           
	dbGotop()
	If dbSeek(xFilial("SZG")+cNumEmb)
		
		While !Eof() .And. SZG->ZG_FILIAL == xFilial("SZG") .And. SZG->ZG_NUMEMB == cNumEmb
			
			dbSelectArea("TMP")
			dbAppend()
			For nCont := 1 To Len(aHeader)
				nPos := FieldPos(aHeader[nCont][2])
				If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
					FieldPut(nPos,(cAlias)->(FieldGet(FieldPos(aHeader[nCont][2]))))
				EndIf
			Next nCont
			TMP->ZG_FLAG := .F.
			dbSelectArea("SZG")
			
			dbSkip()
		EndDo
	EndIf
Else
	dbSelectArea("TMP")
	dbAppend()
	For nCont := 1 To Len(aHeader)
		If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
			nPos := FieldPos(aHeader[nCont][2])
			FieldPut(nPos,CriaVar(aHeader[nCont][2],.T.))
		EndIf
	Next nCont
		TMP->ZG_FLAG := .F.
//		TMP->ZG_SEQUEN:= "01"
EndIf
dbSelectArea("TMP")
dbGoTop()                                 
RestArea(aSaveArea)
Return cNumEmb

User function AInclui()
	Alert("Rotina n�o disponivel, utilize a gera��o de embarque...","Aten��o")
return
Return cEmbarque
              


User Function vLegStat()

Local aLegenda := { { "BR_VERMELHO", 'Plano embarcado total' } , ;  
{ "BR_AMARELO"  ,'Plano embarcado parcial.' }, ;
{ "BR_VERDE", 'Plano nao confirmado embarque'} }

BrwLegenda( 'Rotina de embarque de planos', 'Status ', aLegenda  ) 
Return(.T.)



User Function vAltEmb(cAlias,nReg,nOpc)
Local aSaveArea := GetArea()
Local aCampos := {}                   
Local nOpc    := 4
Local aAltera := {}
Local nOpca := 0
Local cArq 
Local aTpSald := ""
Local lEmbarque
Local oGetDb
Local oDlg
Local oFnt                
Local oEmbarque    
Private lImpresso     := .F.
Private aTela := {}
Private aGets := {}
Private aHeader := {}
Public cInvoice := ""                              

aCampos := U_aHeader(@aAltera)


//+----------------------------------------------------------------+
//| Cria arquivo Temporario para uso com MSGETDB |

U_vCriaTMP(aCampos,@cArq)

//+----------------------------------------------------------------+
//| Carrega dados para MSGETDB |
//+----------------------------------------------------------------+
//cNumEmb := U_EmbCarr(4)

cNumEmb   := SZG->ZG_NUMEMB

dbSelectArea("SZG")
dbSetOrder(5)
if dbSeek(xFilial("SZG")+cNumEmb)

	cInvoice := SZG->ZG_INVOICE
	U_VEmbCarr(cNumEmb, 4)



	DEFINE MSDIALOG oDlg TITLE cCadastro + '... Altera��o...' From 8,0 To 40,120 OF oMainWnd

  	DEFINE FONT oFnt	NAME "Arial" Size 10,15
  	DEFINE FONT oFntCabec NAME "Arial" Size 10, 30
		oTPanel1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,20,.T.,.F.)
		oTPanel1:Align := CONTROL_ALIGN_TOP

	
		@ 4, 005 SAY "EMBARQUE: " PIXEL FONT oFntCabec COLOR CLR_BLUE OF oTPanel1
//		@ 4, 068 SAY "Fornedor:"    SIZE 70,7 PIXEL OF oTPanel1
//		@ 4, 190 SAY "Emissao:" SIZE 70,7 PIXEL OF oTPanel1
//		@ 4, 260 Say "Lote:"    SIZE 70,7 PIXEL OF oTPanel1

//		@ 3, 110 MSGET cNumEmb When .F. SIZE 30,15 PIXEL OF oTPanel1
		@ 4, 070 SAY cNumEmb PIXEL FONT oFntCabec COLOR CLR_BLACK OF oTPanel1
		@ 4, 160 SAY "INVOICE " PIXEL FONT oFntCabec COLOR CLR_BLUE of oTPanel1
		@ 4, 240 MSGET cInvoice   When .T. SIZE 78,7 PIXEL OF oTPanel1
		@ 4, 350 CheckBox oEmbarque Var lEmbarque Prompt "Embarcar ?" Size C(056),C(004) PIXEL FONT oFntCabec COLOR CLR_BLUE OF oTPanel1
//		@ 3, 215 MSGET dData   When .F. SIZE 40,7 PIXEL OF oTPanel1
//		@ 3, 275 MSGET cLote  When .F. SIZE 40,7 PIXEL OF oTPanel1
		oTPanel2 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,24,.T.,.F.)
		oTPanel2:Align := CONTROL_ALIGN_BOTTOM
		If nOpc == 4                                                                                                     
//		oGetDB:= MSGetDB():New(0, 0, 0, 0, Iif(nOpc==3,4,nOpc),"U_cLOk", "U_cTOk", "+ZG_SEQUEN",.t.,aAltera,,.t.,,"TMP")
			oGetDB  := MSGetDB():New(0, 0, 0, 0, Iif(nOpc==3,4,nOpc),"U_vcLok","U_vcTOk", "+ZG_SEQUEN",.t.,aAltera,,.t.,,"TMP",,,,,,,) //"U_cDel")
		Else
			oGetDB := MSGetDados():New(0,0,0,0,nOpc)
		Endif

		oGetDB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
//  	@225,420  BMPBUTTON TYPE 06 ACTION (ExecBlock("U_cTOk(cInvoice)"), ExecBlock("MD_RELEMBPL(cNumEmb)") ) 
	  	@225,420  BMPBUTTON TYPE 06 ACTION if(u_cTok(cNumEmb), {u_GravaEmb(cNumEmb,4,cInvoice, lEmbarque) , U_MD_RELEMBPL(cNumEmb)}, Alert("Acerte as informacoes antes de imprimir..."))

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
				{||nOpca:=1,if(u_vcTok(cNumEmb), (u_GravaEmb(cNumEmb,4,cInvoice, lEmbarque), oDlg:End()),nOpca := 0)},;
				{||nOpca:=2, oDlg:End()}) VALID nOpca != 0 CENTERED
	
else
	Alert("N�o H� Planos a serem embarcados e/ou os planos marcados j� embarcaram...")
endif
DbSelectArea( "TMP" )
DbCloseArea()
If Select("cArq") = 0
	FErase(cArq+GetDBExtension())
EndIf	
	
dbSelectArea("SZG")
dbSetOrder(1)


	
Return nOpca

user function vExcEMB(cAlias,nReg,nOpc)
Local aSaveArea := GetArea()
Local aCampos := {}                   
Local nOpc    := 5
Local aAltera := {}
Local nOpca := 0
Local cArq 
Local aTpSald := ""
Local lEmbarque
Local oGetDb
Local oDlg
Local oFnt                
Local oEmbarque    
Private lImpresso     := .F.
Private aTela := {}
Private aGets := {}
Private aHeader := {}
Public cInvoice := ""                              

aCampos := U_aHeader(@aAltera)


//+----------------------------------------------------------------+
//| Cria arquivo Temporario para uso com MSGETDB |

U_vCriaTMP(aCampos,@cArq)

//+----------------------------------------------------------------+
//| Carrega dados para MSGETDB |
//+----------------------------------------------------------------+
//cNumEmb := U_EmbCarr(4)

cNumEmb   := SZG->ZG_NUMEMB

dbSelectArea("SZG")
dbSetOrder(5)
if dbSeek(xFilial("SZG")+cNumEmb)

	cInvoice := SZG->ZG_INVOICE
	U_VEmbCarr(cNumEmb, 4)



	DEFINE MSDIALOG oDlg TITLE cCadastro + '... Exclusao...' From 8,0 To 40,120 OF oMainWnd

  	DEFINE FONT oFnt	NAME "Arial" Size 10,15
  	DEFINE FONT oFntCabec NAME "Arial" Size 10, 30
		oTPanel1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,20,.T.,.F.)
		oTPanel1:Align := CONTROL_ALIGN_TOP

	
		@ 4, 005 SAY "EMBARQUE: " PIXEL FONT oFntCabec COLOR CLR_BLUE OF oTPanel1
//		@ 4, 068 SAY "Fornedor:"    SIZE 70,7 PIXEL OF oTPanel1
//		@ 4, 190 SAY "Emissao:" SIZE 70,7 PIXEL OF oTPanel1
//		@ 4, 260 Say "Lote:"    SIZE 70,7 PIXEL OF oTPanel1

//		@ 3, 110 MSGET cNumEmb When .F. SIZE 30,15 PIXEL OF oTPanel1
		@ 4, 070 SAY cNumEmb PIXEL FONT oFntCabec COLOR CLR_BLACK OF oTPanel1
		@ 4, 160 SAY "INVOICE " PIXEL FONT oFntCabec COLOR CLR_BLUE of oTPanel1
		@ 4, 240 MSGET cInvoice   When .F. SIZE 78,7 PIXEL OF oTPanel1
//		@ 4, 350 CheckBox oEmbarque Var lEmbarque Prompt "Embarcar ?" Size C(056),C(004) PIXEL FONT oFntCabec COLOR CLR_BLUE OF oTPanel1
//		@ 3, 215 MSGET dData   When .F. SIZE 40,7 PIXEL OF oTPanel1
//		@ 3, 275 MSGET cLote  When .F. SIZE 40,7 PIXEL OF oTPanel1
		oTPanel2 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,24,.T.,.F.)
		oTPanel2:Align := CONTROL_ALIGN_BOTTOM
		If nOpc == 4                                                                                                     
//		oGetDB:= MSGetDB():New(0, 0, 0, 0, Iif(nOpc==3,4,nOpc),"U_cLOk", "U_cTOk", "+ZG_SEQUEN",.t.,aAltera,,.t.,,"TMP")
			oGetDB  := MSGetDB():New(0, 0, 0, 0, Iif(nOpc==3,4,nOpc),"U_vcLok","U_vcTOk", "+ZG_SEQUEN",.t.,aAltera,,.t.,,"TMP",,,,,,,) //"U_cDel")
		elseif nOpc == 5
			oGetDB  := MSGetDB():New(0, 0, 0, 0, Iif(nOpc==3,4,nOpc),"U_vcLok","U_vcTOk", "+ZG_SEQUEN",.t.,aAltera,,.t.,,"TMP",,,,,,,) //"U_cDel")
		Else
			oGetDB  := MSGetDB():New(0,0,0,0,nOpc)
		Endif

		oGetDB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
//  	@225,420  BMPBUTTON TYPE 06 ACTION (ExecBlock("U_cTOk(cInvoice)"), ExecBlock("MD_RELEMBPL(cNumEmb)") ) 
//	  	@225,420  BMPBUTTON TYPE 06 ACTION if(u_cTok(cNumEmb), {u_GravaEmb(cNumEmb,4,cInvoice, lEmbarque) , U_MD_RELEMBPL(cNumEmb)}, Alert("Acerte as informacoes antes de imprimir..."))

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
				{||nOpca:=1, u_ExclEmb(cNumEmb), oDlg:End(),nOpca := 0},;
				{||nOpca:=2, oDlg:End()}) VALID nOpca != 0 CENTERED
	
else
	Alert("N�o H� Planos a serem Excluidos")
endif
DbSelectArea( "TMP" )
DbCloseArea()
If Select("cArq") = 0
	FErase(cArq+GetDBExtension())
EndIf	
	
dbSelectArea("SZG")
dbSetOrder(1)


	
Return nOpca

user function ExclEmb(cNumEmb) 
dbSelectArea("SZG")
dbSetOrder(5)
if dbSeek(xFilial("SZG")+cNumEmb)
	while !eof() .and. SZG->ZG_NUMEMB == cNumEmb  
		dbSelectArea("SC2")
		dbSetOrder(10)
		if dbSeek(xFilial("SC2")+SZG->ZG_PLANO)
			RecLock("SC2", .F.)
			if SC2->C2_QUANT == SZG->ZG_QTDEEMB
				SC2->C2_EMBARC := 'N'
			else
				SC2->C2_EMBARC := 'P'
			endif
			MsUnLoCk("SC2")
		endif
		dbSelectArea("SZG")	
		RecLock("SZG",.F.,.T.)
		dbDelete()
		MsUnlOCK()
		SZG->(dbSkip())
	enddo
endif
		

