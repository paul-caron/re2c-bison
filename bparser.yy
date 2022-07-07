%{
#include <iostream>
#include <string>
#include <fstream>
#include <map>
#include <list>
#include <iomanip>



std::ifstream input_stream;


enum EXPRESSION{
    INTEGER,
    IDENTIFIER,
    ASSIGN,
    PLUS,
    MINUS,
    MULT,
    DIV,
    MODULO,
    EQUAL,
    LESSER,
    GREATER,
    PARENTHESIS
};

struct Expression{
    enum EXPRESSION type;
    std::list<struct Expression> child_expressions; 
};

enum STATEMENT{
    RETURN,
    RETURNVAL,
    WHILE,
    IF,
    VAR,
    EXPSTAT,
    COMPOUND,
    NOP
};

struct Statement{
    enum STATEMENT type;
    std::list<Statement> child_statements;
    struct Expression expression;
};

struct Function{
    std::string identifier;
    struct Statement statement;
    std::list<std::string> params;
};


%}

%require "3.2"
%language "c++"
%define api.value.type variant
%define api.token.constructor

%token <std::string> IDENTIFIER
%token <int> INTEGER

%token WHILE IF VAR  RETURN
%token LEFTCURLY RIGHTCURLY

%token PLUS MINUS MULT DIV MODULO EQUAL GREATER LESSER ASSIGN
%token LEFTPAR RIGHTPAR

%token COLON SEMICOLON
%token <std::string> OTHER

%right ASSIGN 
%left EQUAL GREATER LESSER
%left PLUS MINUS
%left MULT DIV MODULO
%left LEFTPAR RIGHTPAR

%code{
namespace yy{

parser::symbol_type yylex(){
    std::string input;
    input_stream >> input;
    
    if(!input.size()) return parser::make_YYEOF();
    const char * start = input.c_str();
    const char * YYCURSOR = start, * YYMARKER;
    
    int len = input.size();
    auto putback = [&YYCURSOR, &len](){
        while(*YYCURSOR){
            input_stream.unget();
            ++YYCURSOR;
            --len;
        }
    };



    /*!re2c
    re2c:define:YYCTYPE = char;
    re2c:yyfill:enable = 0;

        

    *          {return parser::make_OTHER(input);}
    "while"    {putback(); return parser::make_WHILE();}
    "if"       {putback(); return parser::make_IF();}
    "return"   {putback(); return parser::make_RETURN();}
    "var"      {putback(); return parser::make_VAR();}
    [0-9]+     {putback(); return parser::make_INTEGER(strtoll(input.c_str(),0,10));}
    "+"        {putback(); return parser::make_PLUS();}
    "-"        {putback(); return parser::make_MINUS();}
    "*"        {putback(); return parser::make_MULT();}
    "/"        {putback(); return parser::make_DIV();}
    "%"        {putback(); return parser::make_MODULO();}
    "=="       {putback(); return parser::make_EQUAL();}
    ">"        {putback(); return parser::make_GREATER();}
    "<"        {putback(); return parser::make_LESSER();}
    "="        {putback(); return parser::make_ASSIGN();}
    ";"        {putback(); return parser::make_SEMICOLON();}
    ":"        {putback(); return parser::make_COLON();}
    "{"        {putback(); return parser::make_LEFTCURLY();}
    "}"        {putback(); return parser::make_RIGHTCURLY();}
    "("        {putback(); return parser::make_LEFTPAR();}
    ")"        {putback(); return parser::make_RIGHTPAR();}
    [a-zA-Z_]+  {putback(); return parser::make_IDENTIFIER(input.substr(0,len));}



*/
}

}
}

%%

%nterm <struct Expression> expression;
%nterm <struct Statement> statement;
%nterm <struct Statement> compound_statement;
%nterm <struct Function> function;
%nterm <std::list<struct Function>> library;
%nterm <std::list<std::string>> params;

result:
    library {
        for(auto function: $1){
            std::cout<<function.identifier<<std::endl;
            for(auto param: function.params){
                std::cout<<"    "<<param<<std::endl;
            }
            std::cout<<"    "<<function.statement.type<<std::endl;
            for(auto c: function.statement.child_statements){
            std::cout <<"        "<< c.type << std::endl;
            for(auto cc: c.child_statements){
            std::cout <<"            "<< cc.type << std::endl;
            for(auto ccc: cc.child_statements){
            std::cout <<"                "<< ccc.type << std::endl;
            for(auto cccc: ccc.child_statements){
            std::cout <<"                    "<< cccc.type << std::endl;

            }            
            }            
             }
            }            
        }
    }
;

library:
    %empty {$$=std::list<Function>();}
|   library function {$$ = $1; $$.push_back($2);}
;

function:
    IDENTIFIER statement {$$ = {$1,$2};}
|   IDENTIFIER LEFTPAR params RIGHTPAR statement {$$ = {$1,$5,$3};}
;

params:
    %empty {$$ = std::list<std::string>();}
|   params COLON IDENTIFIER {$$ = $1; $$.push_back($3);}
;


statement:
    compound_statement RIGHTCURLY {$$ = $1; $$.type = COMPOUND;}
|   expression SEMICOLON {$$ = {EXPSTAT};}
|   IF LEFTPAR expression RIGHTPAR statement {$$ = {IF};$$.child_statements.push_back($5);}
|   WHILE LEFTPAR expression RIGHTPAR statement {$$ = {WHILE};$$.child_statements.push_back($5);}
|   RETURN SEMICOLON {$$ = {RETURN};}
|   RETURN expression SEMICOLON {$$ = {RETURNVAL};}
|   VAR IDENTIFIER SEMICOLON {$$ = {VAR};}
|   SEMICOLON {$$ = {NOP};}
;

compound_statement:
    LEFTCURLY {}
|   compound_statement statement {$$ = $1; $$.child_statements.push_back($2);}
;

expression:
    INTEGER {$$={INTEGER};}
|   expression ASSIGN expression {$$={ASSIGN};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression PLUS expression {$$={PLUS};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression MINUS expression {$$={MINUS};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression MULT expression {$$={MULT};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression DIV expression {$$={DIV};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression MODULO expression {$$={MODULO};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression EQUAL expression {$$={EQUAL};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression LESSER expression {$$={LESSER};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression GREATER expression {$$={GREATER};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   LEFTPAR expression RIGHTPAR {$$={PARENTHESIS};}
|   IDENTIFIER {$$={IDENTIFIER};}

;


%%

namespace yy{
    void parser::error (const std::string& msg){
        std::cerr << "Parsing error: " << msg << std::endl;
    }
};

int main(int argc, char ** argv){
    if(argc >= 2){
        input_stream.open(argv[1]);
    }
    yy::parser parse;
    parse();

    #ifdef DEBUG
    
    #endif
    
    

    return 0;
}


