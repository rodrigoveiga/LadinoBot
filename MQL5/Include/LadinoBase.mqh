//+------------------------------------------------------------------+
//|                                                   LadinotBot.mqh |
//|                                                   Rodrigo Landim |
//|                                        http://www.emagine.com.br |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Landim"
#property link      "http://www.emagine.com.br"
#property version   "1.00"

#include <trade/trade.mqh>
#include <Utils.mqh>
#include <LogPanel.mqh>
#include <LadinoHiLo.mqh>
#include <LadinoTrade.mqh>
#include <LadinoUtils.mqh>
   
//+------------------------------------------------------------------+

class LadinoBase: public LadinoTrade {
   private:
      SITUACAO_ROBO     _statusAtual;

      //double hiloAtual;
      int diaAtual, fractalHandle;
   
      // Parametros
      ENUM_HORARIO      _HorarioEntrada;
      ENUM_HORARIO      _HorarioFechamento;
      ENUM_HORARIO      _HorarioSaida;
      ATIVO_TIPO        _TipoAtivo;
      TIPO_GESTAO_RISCO _GestaoRisco;
      CONDICAO_ENTRADA  _CondicaoEntrada;
      //double            _Corretagem;
      double            _ValorPonto;
      double            _ganhoMaximoPosicao;

      void inicializarVariavel();
      void inicializarParametro();
   protected:
      bool tendenciaMudou, posicionado;
      
      SENTIDO_OPERACAO  _TipoOperacao;
      int               _InicialVolume;
      double            _volumeAtual;
      double            _precoCompra, _precoVenda;
      double            _ultimoStopMax;
      int               _MaximoVolume;
      OPERACAO_SITUACAO operacaoAtual;
      
      void inicializarBasico();
   public:
      LadinoBase(void);
      
      SITUACAO_ROBO getStatusAtual();
      
      ENUM_HORARIO getHorarioEntrada();
      void setHorarioEntrada(ENUM_HORARIO value);
      ENUM_HORARIO getHorarioFechamento();
      void setHorarioFechamento(ENUM_HORARIO value);
      ENUM_HORARIO getHorarioSaida();
      void setHorarioSaida(ENUM_HORARIO value);
      SENTIDO_OPERACAO getTipoOperacao();
      void setTipoOperacao(SENTIDO_OPERACAO value);
      ATIVO_TIPO getTipoAtivo();
      void getTipoAtivo(ATIVO_TIPO value);
      TIPO_GESTAO_RISCO getGestaoRisco();
      void setGestaoRisco(TIPO_GESTAO_RISCO value);
      CONDICAO_ENTRADA getCondicaoEntrada();
      void setCondicaoEntrada(CONDICAO_ENTRADA value);
      //double getCorretagem();
      //void setCorretagem(double value);
      double getValorPonto();
      void setValorPonto(double value);
      int getInicialVolume();
      void setInicialVolume(int value);
      int getMaximoVolume();
      void setMaximoVolume(int value);
      double getGanhoMaximoPosicao();
      void setGanhoMaximoPosicao(double valor);
      
      void ativar();
      void fechar();

      void desativar();
      void atualizarPreco();
      
      void alterarOperacaoAtual();

      void onTick();
      void onTimer();
      double onTester();
      
      virtual bool verificarEntrada();
      virtual bool verificarSaida();
};

LadinoBase::LadinoBase(void) {
   inicializarVariavel();
   inicializarParametro();
}

SITUACAO_ROBO LadinoBase::getStatusAtual() {
   return _statusAtual;
}

void LadinoBase::inicializarBasico() {
   MqlDateTime tempo;
   TimeToStruct(iTimeMQL4(_Symbol,_Period,0), tempo);
   diaAtual = tempo.day_of_year;
   _statusAtual = INICIALIZADO;
   if (horarioCondicao(_HorarioEntrada, IGUAL_OU_MAIOR_QUE) && horarioCondicao(_HorarioFechamento, IGUAL_OU_MENOR_QUE))
      ativar();       
}

void LadinoBase::inicializarVariavel() {
   _volumeAtual = 0;

   tendenciaMudou = false;
   posicionado = false;

   //hiloAtual = 0;
   _precoCompra = 0;
   _precoVenda = 0;

   operacaoAtual = SITUACAO_FECHADA;

   _ultimoStopMax = 0;
   diaAtual = 0;

   fractalHandle = 0;

   _statusAtual = INATIVO;
}

void LadinoBase::inicializarParametro() {
   _HorarioEntrada = HORARIO_1000;
   _HorarioFechamento = HORARIO_1600;
   _HorarioSaida = HORARIO_1630;
   _TipoOperacao = COMPRAR_VENDER;
   _TipoAtivo = ATIVO_INDICE;
   _GestaoRisco = RISCO_NORMAL;
   _CondicaoEntrada = HILO_CRUZ_MM_T1_FECHAMENTO;
   //_Corretagem = 1;
   _ValorPonto = 0.2;
   
   _InicialVolume = 1;
   _MaximoVolume = 1;
}

ENUM_HORARIO LadinoBase::getHorarioEntrada() {
   return _HorarioEntrada;
}

void LadinoBase::setHorarioEntrada(ENUM_HORARIO value) {
   _HorarioEntrada = value;
}

ENUM_HORARIO LadinoBase::getHorarioFechamento() {
   return _HorarioFechamento;
}

void LadinoBase::setHorarioFechamento(ENUM_HORARIO value) {
   _HorarioFechamento = value;
}

ENUM_HORARIO LadinoBase::getHorarioSaida(){
   return _HorarioSaida;
}

void LadinoBase::setHorarioSaida(ENUM_HORARIO value) {
   _HorarioSaida = value;
}

SENTIDO_OPERACAO LadinoBase::getTipoOperacao() {
   return _TipoOperacao;
}

void LadinoBase::setTipoOperacao(SENTIDO_OPERACAO value) {
   _TipoOperacao = value;
}

ATIVO_TIPO LadinoBase::getTipoAtivo() {
   return _TipoAtivo;
}

void LadinoBase::getTipoAtivo(ATIVO_TIPO value) {
   _TipoAtivo = value;
}

TIPO_GESTAO_RISCO LadinoBase::getGestaoRisco() {
   return _GestaoRisco;
}

void LadinoBase::setGestaoRisco(TIPO_GESTAO_RISCO value) {
   _GestaoRisco = value;
}

CONDICAO_ENTRADA LadinoBase::getCondicaoEntrada() {
   return _CondicaoEntrada;
}

void LadinoBase::setCondicaoEntrada(CONDICAO_ENTRADA value) {
   _CondicaoEntrada = value;
}

/*
double LadinoBase::getCorretagem() {
   return _Corretagem;
}

void LadinoBase::setCorretagem(double value) {
   _Corretagem = value;
}
*/

double LadinoBase::getValorPonto() {
   return _ValorPonto;
}

void LadinoBase::setValorPonto(double value) {
   _ValorPonto = value;
}


int LadinoBase::getInicialVolume() {
   return _InicialVolume;
}

void LadinoBase::setInicialVolume(int value) {
   _InicialVolume = value;
}

int LadinoBase::getMaximoVolume() {
   return _MaximoVolume;
}

void LadinoBase::setMaximoVolume(int value) {
   _MaximoVolume = value;
}

double LadinoBase::getGanhoMaximoPosicao() {
   return _ganhoMaximoPosicao;
}

void LadinoBase::setGanhoMaximoPosicao(double valor) {
   _ganhoMaximoPosicao = valor;
}

void LadinoBase::ativar() {
   if (_statusAtual != ATIVO) {
      _statusAtual = ATIVO;
      escreverLog("LadinoHiLo active for trading!");
      
      double volMinimo = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
      double volMaximo = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
      double volPasso = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
      
      _volumeAtual = _InicialVolume;
      _volumeAtual = _volumeAtual - MathMod(_volumeAtual, volPasso);
      
      if (_volumeAtual < volMinimo)
         _volumeAtual = volMinimo;
      if (_volumeAtual > volMaximo)
         _volumeAtual = volMaximo;
         
      escreverLog("Volume " + IntegerToString((int) _volumeAtual) + " to be traded...");
   }
}

void LadinoBase::fechar() {
   if (_statusAtual != FECHANDO) {
      _statusAtual = FECHANDO;
      escreverLog("LadinoHiLo closed to new trades! Current Financial = " + StringFormat("%.2f", this.getTotal()));
   }
}

void LadinoBase::desativar() {
   if (_statusAtual != INATIVO) {
      _statusAtual = INATIVO;
      if(PositionSelect(_Symbol)) {
         escreverLog("Disabling LadinoHiLo, closing all open positions.");
         this.finalizarPosicao();
      }
      escreverLog("LadinoHiLo disabled for trading! Current Financial =" + StringFormat("%.2f", this.getTotal()));
   }
}

void LadinoBase::alterarOperacaoAtual() {
   if (operacaoAtual == SITUACAO_ABERTA || operacaoAtual == SITUACAO_BREAK_EVEN)
      operacaoAtual = SITUACAO_OBJETIVO1;
   else if (operacaoAtual == SITUACAO_OBJETIVO1)
      operacaoAtual = SITUACAO_OBJETIVO2;
   else if (operacaoAtual == SITUACAO_OBJETIVO2)
      operacaoAtual = SITUACAO_OBJETIVO3;
}

void LadinoBase::atualizarPreco() {
   // Preço atual
   double tickMinimo = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double preco = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   preco = NormalizeDouble(preco, _Digits);
   preco = preco - MathMod(preco, tickMinimo);
   if (preco != _precoCompra)
      _precoCompra = preco;
   
   preco = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   preco = NormalizeDouble(preco, _Digits);
   preco = preco - MathMod(preco, tickMinimo);
   if (preco != _precoVenda)
      _precoVenda = preco;
}

void LadinoBase::onTick() {
   if (_statusAtual == ATIVO) {
      if(PositionSelect(_Symbol))
         verificarSaida();
      else
         verificarEntrada();
   }
   else if (_statusAtual == FECHANDO) {
      if(PositionSelect(_Symbol))
         verificarSaida();
   }
}

void LadinoBase::onTimer() {
   MqlDateTime tempo;
   TimeToStruct(iTimeMQL4(_Symbol,_Period,0), tempo);
   if (diaAtual != tempo.day_of_year) {
      this.fecharDia();
      _statusAtual = INICIALIZADO;
      diaAtual = tempo.day_of_year;
   }
   
   if (_statusAtual == INICIALIZADO) {
      if (horarioCondicao(getHorarioEntrada(), IGUAL_OU_MAIOR_QUE))
         ativar();      
   }   
   else if (_statusAtual == ATIVO) {
      if (horarioCondicao(getHorarioFechamento(), IGUAL_OU_MAIOR_QUE))
         fechar();
      if (horarioCondicao(getHorarioSaida(), IGUAL_OU_MAIOR_QUE))
         desativar();
   }
   else if (_statusAtual == INATIVO) {

   }
   else if (_statusAtual == FECHANDO) {
      if (horarioCondicao(getHorarioSaida(), IGUAL_OU_MAIOR_QUE))
         desativar();
   }
}

double LadinoBase::onTester() {
   this.fecharDia();
   string msg = "TESTE FINALIZADO!";
   msg += " s/f=" + IntegerToString(this.getSucessoTotal()) + "/" + IntegerToString(this.getFalhaTotal());
   msg += ", c=" + StringFormat("%.2f", this.getCorretagemTotal()) + ".";
   msg += ", $=" + StringFormat("%.2f", this.getTotal());
   escreverLog(msg);
   return 0;
}

bool LadinoBase::verificarEntrada() {
   return false;
}
bool LadinoBase::verificarSaida() {
   return false;
}