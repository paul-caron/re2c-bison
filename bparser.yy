

%{
#include <iostream>
#include <string>
#include <fstream>

std::ifstream input_stream;

%}

%require "3.2"
%language "c++"
%define api.value.type variant
%define api.token.constructor

%token <std::string> IDENTIFIER
%token <int> INTEGER
%token PLUS MINUS MULT DIV MODULO EQUAL GREATER LESSER ASSIGN
%token COLON SEMICOLON
%token LEFTCURLY RIGHTCURLY
%token LEFTPAR RIGHTPAR
%token WHILE IF VAR  RETURN
%token <std::string> OTHER

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
    [0-9]+     {putback(); return parser::make_INTEGER(strtoll(input.c_str(),0,10));}
    [a-zA-Z_]+  {putback(); return parser::make_IDENTIFIER(input.substr(0,len));}
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
    "var"      {putback(); return parser::make_VAR();}      
    "while"    {putback(); return parser::make_WHILE();}
    "if"       {putback(); return parser::make_IF();}
    "return"   {putback(); return parser::make_RETURN();}


*/
}

}
}

%%

line:
|    line input
;



input:
    INTEGER     {std::cout << "number: " << $1 << std::endl;}
|   IDENTIFIER  {std::cout << "identifier: " << $1 << std::endl;}
|   PLUS        {std::cout << "plus" << std::endl;}
|   MINUS       {std::cout << "minus" << std::endl;}
|   MULT        {std::cout << "mult" << std::endl;}
|   DIV         {std::cout << "div" << std::endl;}
|   MODULO      {std::cout << "modulo" << std::endl;}
|   EQUAL       {std::cout << "equal" << std::endl;}
|   GREATER     {std::cout << "greater" << std::endl;}
|   LESSER      {std::cout << "lesser" << std::endl;}
|   ASSIGN      {std::cout << "assign" << std::endl;}
|   SEMICOLON   {std::cout << "semicolon" << std::endl;}
|   COLON       {std::cout << "colon" << std::endl;}
|   LEFTCURLY   {std::cout << "left curly bracket" << std::endl;}
|   RIGHTCURLY  {std::cout << "right curly bracket" << std::endl;}
|   LEFTPAR     {std::cout << "left par" << std::endl;}
|   RIGHTPAR    {std::cout << "right par" << std::endl;}
|   VAR         {std::cout << "var" << std::endl;}
|   WHILE       {std::cout << "while" << std::endl;}
|   IF          {std::cout << "if" << std::endl;}
|   RETURN      {std::cout << "return" << std::endl;}
|   OTHER       {yy::parser::error($1 + " cannot be parsed");}
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
    return 0;
}

