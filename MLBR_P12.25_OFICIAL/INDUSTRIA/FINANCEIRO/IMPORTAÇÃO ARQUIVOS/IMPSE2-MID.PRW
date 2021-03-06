#INCLUDE "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � IMPSE2   � Autor � Paulo R. Trivellato� Data �  28/06/2009 ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 10                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function IMPSE2

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Private cPerg       := "SE2111"
Private oLeTxt

Private cString := "SE2"

dbSelectArea("SE2")
dbSetOrder(1)

//���������������������������������������������������������������������Ŀ
//� Montagem da tela de processamento.                                  �
//�����������������������������������������������������������������������

@ 200,1 TO 380,380 DIALOG oLeTxt TITLE OemToAnsi("Leitura de Arquivo Texto")
@ 02,10 TO 080,190
@ 10,018 Say " Este programa ira ler o conteudo de um arquivo texto, conforme"
@ 18,018 Say " os parametros definidos pelo usuario, com os registros do arquivo"
@ 26,018 Say " SE2                                                           "

@ 70,128 BMPBUTTON TYPE 01 ACTION OkLeTxt()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)
@ 70,188 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)

Activate Dialog oLeTxt Centered

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � OKLETXT  � Autor � AP6 IDE            � Data �  28/06/09   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao chamada pelo botao OK na tela inicial de processamen���
���          � to. Executa a leitura do arquivo texto.                    ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function OkLeTxt

//���������������������������������������������������������������������Ŀ
//� Abertura do arquivo texto                                           �
//�����������������������������������������������������������������������

Private cArqTxt := "C:\TOTVS\EXPCTPG.TXT"
Private nHdl    := fOpen(cArqTxt,68)

Private cEOL    := "CHR(13)+CHR(10)"
If Empty(cEOL)
	cEOL := CHR(13)+CHR(10)
Else
	cEOL := Trim(cEOL)
	cEOL := &cEOL
Endif

If nHdl == -1
	MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser aberto! Verifique os parametros.","Atencao!")
	Return
Endif

//���������������������������������������������������������������������Ŀ
//� Inicializa a regua de processamento                                 �
//�����������������������������������������������������������������������

Processa({|| RunCont() },"Processando...")

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � RUNCONT  � Autor � AP5 IDE            � Data �  28/06/09   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RunCont

Local nTamFile, nTamLin, cBuffer, nBtLidos
Local aVetor := {}
Local _cCGCCli := ""
Local _cCodCli := Space(6)
Local _cLojCli := Space(2)

//�����������������������������������������������������������������ͻ
//� Lay-Out do arquivo Texto gerado:                                �
//�����������������������������������������������������������������͹
//�Campo           � Inicio � Tamanho                               �
//�����������������������������������������������������������������Ķ
//� E2_FILIAL      � 01     � 02                                    �
//� E2_PREFIXO     � 03     � 03                                    �
//� E2_NUM	       � 06     � 09                                    �
//� E2_PARC        � 15     � 02                                    �
//� E2_TIPO        � 17     � 03                                    �
//� E2_CLIENTE     � 20     � 06                                    �
//� E2_LOJA        � 26     � 02                                    �
//� E2_VALOR       � 28     � 17                                    �
//� E2_EMISSAO     � 45     � 08                                    �
//� E2_VENCTO      � 53     � 08                                    �
//� E2_VENCREA     � 61     � 08                                    �
//� E2_SALDO       � 69     � 17                                    �
//�����������������������������������������������������������������ͼ

nTamFile := fSeek(nHdl,0,2)
fSeek(nHdl,0,0)
nTamLin  := 483+Len(cEOL)
cBuffer  := Space(nTamLin) // Variavel para criacao da linha do registro para leitura

nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da primeira linha do arquivo texto

ProcRegua(nTamFile) // Numero de registros a processar

While nBtLidos >= nTamLin
	
	//���������������������������������������������������������������������Ŀ
	//� Incrementa a regua                                                  �
	//�����������������������������������������������������������������������
	
	IncProc()
	
	//���������������������������������������������������������������������Ŀ
	//� Grava os campos obtendo os valores da linha lida do arquivo texto.  �
	//�����������������������������������������������������������������������
	//	dbSelectArea(cString)
	//	RecLock(cString,.T.)

	//_cEmissao := STOD(Substr(cBuffer,69,04)+Substr(cBuffer,67,02)+Substr(cBuffer,65,02))
	//_cVencto  := STOD(Substr(cBuffer,77,04)+Substr(cBuffer,75,02)+Substr(cBuffer,73,02))
	//_cVencRea := STOD(Substr(cBuffer,85,04)+Substr(cBuffer,83,02)+Substr(cBuffer,81,02))

	_cCGCCli := Substr(cBuffer,470,14)
	dbSelectArea("SA2")
	dbSetOrder(3)
	If dbSeek(xFilial("SA2") + _cCGCCli )
		_cCodCli := SA2->A2_COD
		_cLojCli := SA2->A2_LOJA
	Else
		_cCodCli := "000001"
		_cLojCli := "01"
	EndIf

	//{"E2_TIPO"	  ,IIF(Substr(cBuffer,16,03)=="ND ","NDF",Substr(cBuffer,16,03)),Nil},;

	aVetor:= {{"E2_PREFIXO" ,Substr(cBuffer,03,03),Nil},;
		  		{"E2_NUM"	  ,Substr(cBuffer,06,09),Nil},;
				{"E2_PARCELA" ,Substr(cBuffer,15,01),Nil},;
				{"E2_TIPO"	  ,IIF(Substr(cBuffer,16,03)=="ADT","NDF",IIF(Substr(cBuffer,16,03)=="ND","NDF","DP ")),Nil},;
				{"E2_NATUREZ" ,"IMP"           ,Nil},;
	    	    {"E2_FORNECE" ,_cCodCli        ,Nil},;
            	{"E2_LOJA"	  ,_cLojCli        ,Nil},;
            	{"E2_NOMEFOR" ,Substr(cBuffer,40,20),Nil},;
		        {"E2_EMISSAO" ,STOD(Substr(cBuffer,64,04)+Substr(cBuffer,62,02)+Substr(cBuffer,60,02)),Nil},;
			    {"E2_VENCTO"  ,STOD(Substr(cBuffer,72,04)+Substr(cBuffer,70,02)+Substr(cBuffer,68,02)),Nil},;
			    {"E2_VENCREA" ,STOD(Substr(cBuffer,80,04)+Substr(cBuffer,78,02)+Substr(cBuffer,76,02)),Nil},;
		    	{"E2_VALOR"	  ,NoRound(Val(Substr(cBuffer,84,17)),02),Nil},;
			    {"E2_SALDO"	  ,NoRound(Val(Substr(cBuffer,177,17)),02),Nil},;
			    {"E2_LA"	  ,"S",Nil},;
			    {"E2_HIST"	  ,"IMPORTA��O SISTEMA LEGADO - WK",Nil},;
			    {"E2_ORIGEM"  ,"IMPSE2",Nil}}

/*
		{"E2_EMISSAO" ,CTOS(Substr(cBuffer,65,08)),Nil},;
		{"E2_VENCTO"  ,CTOS(Substr(cBuffer,73,08)),Nil},;
		{"E2_VENCREA" ,CTOS(Substr(cBuffer,81,08)),Nil},;

	SE2->E2_FILIAL	:= Substr(cBuffer,01,02)
	SE2->E2_PREFIXO	:= Substr(cBuffer,03,03)
	SE2->E2_NUM		:= Substr(cBuffer,06,09)
	SE2->E2_PARC	:= Substr(cBuffer,15,02)
	SE2->E2_TIPO	:= Substr(cBuffer,17,03)
	SE2->E2_CLIENTE	:= Substr(cBuffer,20,06)
	SE2->E2_LOJA	:= Substr(cBuffer,26,02)
	SE2->E2_VALOR	:= NoRound(Val(Substr(cBuffer,28,17)),02)
	SE2->E2_EMISSAO	:= CTOD(Substr(cBuffer,45,08))
	SE2->E2_VENCTO	:= CTOD(Substr(cBuffer,53,08))
	SE2->E2_VENCREA	:= CTOD(Substr(cBuffer,61,08))
	SE2->E2_SALDO	:= NoRound(Val(Substr(cBuffer,69,17)),02)
	MSUnLock()
*/
	
	//���������������������������������������������������������������������Ŀ
	//� Leitura da proxima linha do arquivo texto.                          �
	//�����������������������������������������������������������������������

	MSExecAuto({|x,y| Fina050(x,y)},aVetor,3) //3-Inclusao  /5-Exclusao
	
	nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da proxima linha do arquivo texto
	
	dbSkip()
EndDo

//���������������������������������������������������������������������Ŀ
//� O arquivo texto deve ser fechado, bem como o dialogo criado na fun- �
//� cao anterior.                                                       �
//�����������������������������������������������������������������������

fClose(nHdl)
Close(oLeTxt)

Return