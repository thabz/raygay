
#include "scheme.h"
#include "lexer.h"
#include "parser.h"

#define assert_eval(s,e,b) assert(s->eval(e)->toString() == b)

void test_tokenizer() {
    Lexer* l = new Lexer("(+ 1.5 (2 . \"Hej\") .x)");
    assert(l->nextToken() == Lexer::OPEN_PAREN);
    assert(l->nextToken() == Lexer::SYMBOL);
    assert(l->getString() == "+");
    assert(l->nextToken() == Lexer::NUMBER);
    assert(l->getNumber() == 1.5);
    assert(l->nextToken() == Lexer::OPEN_PAREN);
    assert(l->nextToken() == Lexer::NUMBER);
    assert(l->getNumber() == 2);
    assert(l->nextToken() == Lexer::PERIOD);
    assert(l->nextToken() == Lexer::STRING);
    assert(l->getString() == "Hej");
    assert(l->nextToken() == Lexer::CLOSE_PAREN);
    assert(l->nextToken() == Lexer::SYMBOL);
    assert(l->nextToken() == Lexer::CLOSE_PAREN);
    assert(l->nextToken() == Lexer::END);
    delete l;

    l = new Lexer("#f #tf");
    assert(l->nextToken() == Lexer::BOOLEAN);
    assert(l->getBool() == false);
    assert(l->nextToken() == Lexer::BOOLEAN);
    assert(l->getBool() == true);
    assert(l->nextToken() == Lexer::SYMBOL);
    assert(l->nextToken() == Lexer::END);
    
    l = new Lexer("a");
    assert(l->nextToken() == Lexer::SYMBOL);
    assert(l->getString() == "a");
    assert(l->nextToken() == Lexer::END);
}

void test_parser() {
    Lexer* l = new Lexer("(+ 1.5 (list? \"Hej\"))");
    Parser* p = new Parser(l);
    SchemePair* t = p->parse();
    SchemePair* e = static_cast<SchemePair*> (t->car);
    assert(e->car->type() == SchemeObject::SYMBOL);
    assert(e->cdrAsPair()->car->type() == SchemeObject::NUMBER);
    SchemePair* inner = static_cast<SchemePair*> (e->cdrAsPair()->cdrAsPair()->car);
    assert(inner->car->type() == SchemeObject::SYMBOL);
    assert(inner->car->toString() == "list?");
    assert(inner->cdrAsPair()->car->type() == SchemeObject::STRING);
    assert(inner->cdrAsPair()->cdrAsPair()->type() == SchemeObject::EMPTY_LIST);
    assert(e->cdrAsPair()->cdrAsPair()->cdrAsPair()->type() == SchemeObject::EMPTY_LIST);
    
    l = new Lexer("'(x . y)");
    p = new Parser(l);
    t = p->parse();
    e = static_cast<SchemePair*> (t->car);
    assert(e->car->type() == SchemeObject::SYMBOL);
    assert(e->cdrAsPair()->car->type() == SchemeObject::PAIR);
    assert(static_cast<SchemePair*>(e->cdrAsPair()->car)->car->type() == SchemeObject::SYMBOL);
    assert(static_cast<SchemePair*>(e->cdrAsPair()->car)->car->toString() == "x");
    assert( static_cast<SchemePair*>(e->cdrAsPair()->car)->cdr->toString() == "y");
}

void test_bools() {
    Scheme* s = new Scheme();
    assert(s->eval("(bool? #t)") == S_TRUE);
    assert(s->eval("(bool? #f)") == S_TRUE);
    assert(s->eval("(bool? 1)") == S_FALSE);
    assert(s->eval("(bool? '(1 2 3))") == S_FALSE);
}

void test_symbols() {
    Scheme* s = new Scheme();
    assert(s->eval("(symbol? (quote a))") == S_TRUE);
    assert(s->eval("(symbol? 'a)") == S_TRUE);
    assert(s->eval("(symbol? '1)") == S_FALSE);
    assert(s->eval("(symbol? '())") == S_FALSE);
    assert(s->eval("(symbol? 1)") == S_FALSE);
    assert(SchemeSymbol::create("a") == SchemeSymbol::create("a"));
    assert(SchemeSymbol::create("a") != SchemeSymbol::create("b"));
}

void test_interpreter() {
    // test eval_combo()
    Scheme* s = new Scheme();
    assert_eval(s, "((if #t reverse length) '(1 2 3))", "(3 2 1)");
    assert_eval(s, "((if #f reverse length) '(1 2 3))", "3");
    assert_eval(s, "((if #f reverse length) '(1 2 3))", "3");
    
    // test define
    assert_eval(s, "(define a 10) a", "10");
    
    // test built-in with only rst args
    assert_eval(s, "(+ 10 9 2 19 8 2 1 29 8 8 2 1 23 3 1) ", "126");
    delete s;
}

void test_equals() {
    Scheme* s = new Scheme();
    assert_eval(s, "(equal? 1 1)" , "#t");
    assert_eval(s, "(equal? 1 2)" , "#f");
    assert_eval(s, "(equal? \"abc\" \"abc\")" , "#t");
    assert_eval(s, "(equal? '(1 2 3) '(1 2 3))" , "#t");
    assert_eval(s, "(equal? '(1 2 (a  b) 3) '(1 2 (a b) 3))" , "#t");
    assert_eval(s, "(equal? '(1 2 (a c) 3) '(1 2 (a b) 3))" , "#f");
}

void test_pairs_and_lists() {
    SchemePair* p = s_cons(SchemeSymbol::create("x"),SchemeSymbol::create("y"));
    assert(p->toString() == "(x . y)");
    
    Scheme* s = new Scheme();
    assert(s->eval("(list? '())") == S_TRUE);
    assert(s->eval("(list? '(1 2 3))") == S_TRUE);
    assert(s->eval("(list? 1)") == S_FALSE);
    assert(s->eval("(list? '(1 2 . 3))") == S_FALSE);
    assert(s->eval("(pair? 1)") == S_FALSE);
    assert(s->eval("(pair? '())") == S_FALSE);
    assert(s->eval("(pair? '(1 2))") == S_TRUE);
    assert(s->eval("(pair? '(1 2 . 3))") == S_TRUE);
    
    assert_eval(s, "(cons 1 2)", "(1 . 2)");
    
    assert_eval(s, "(list)", "()");
    assert_eval(s, "(list 1)", "(1)");
    assert_eval(s, "(list '())", "(())");
    assert_eval(s, "(list 1 2 (+ 1 2) 4)", "(1 2 3 4)");

    assert_eval(s, "(car (cons 1 2))", "1");
    assert_eval(s, "(cdr (cons 1 2))", "2");
    assert_eval(s, "(cdr (list 1 2))", "(2)");

    assert_eval(s, "(member 3 '(1 2 3 4 5))", "(3 4 5)");
    assert_eval(s, "(member 10 '(1 2 3 4 5))", "#f");
    assert_eval(s, "(member 10 '())", "#f");

    assert_eval(s, "(list-tail '(1 2 3 4 5) 0)", "(1 2 3 4 5)");
    assert_eval(s, "(list-tail '(1 2 3 4 5) 1)", "(2 3 4 5)");
    assert_eval(s, "(list-tail '() 0)", "()");

    assert_eval(s, "(list-ref '(1 2 3) 0)", "1");
    assert_eval(s, "(list-ref '(1 2 3) 1)", "2");
    assert_eval(s, "(list-ref '(1 2 3) 2)", "3");
}

void test_lambda() {
    Scheme* s = new Scheme();
    assert_eval(s, "(procedure? (lambda (x) x))", "#t");
    assert_eval(s, "(procedure? cons)", "#t");
    assert_eval(s, "(procedure? 1)", "#f");
    assert_eval(s, "((lambda () 3))", "3");
    assert_eval(s, "((lambda (x) (* 2 x)) 10)", "20");
    assert_eval(s, "((lambda (x y) (+  y x)) 7 10)", "17");
    // Two examples from R^5RS
    assert_eval(s, "((lambda x x) 3 4 5 6)", "(3 4 5 6)");
    assert_eval(s, "((lambda (x y . z) z) 3 4 5 6)", "(5 6)");
}

void test_define_and_set() {
    Scheme* s = new Scheme();
    s->eval("(define x 17)");
    assert_eval(s, "x", "17");
    s->eval("(set! x 20)");
    assert_eval(s, "x", "20");
    s->eval("(define (square x) (* x x))");
    assert_eval(s, "(square 9)", "81");
    s->eval("(define (selftest . x) x)");
    // A R^5RS spec that guile 1.6.8 fails but we don't... :-)
    assert_eval(s, "(selftest 1 2 3 4)", "(1 2 3 4)");
    s->eval("(define (fact n) (if (equal? n 1) 1 (* n (fact (- n 1)))))");
    assert_eval(s, "(fact 6)", "720");
}

void test_string() {
    Scheme* s = new Scheme();
    assert_eval(s, "(string? 1)", "#f");
    assert_eval(s, "(string? \"\")", "#t");
    assert_eval(s, "(string? \"a\")", "#t");
    assert_eval(s, "(string? ((lambda () \"a\")))", "#t");
}

void test_begin() {
    Scheme* s = new Scheme();
    assert_eval(s, "(begin 1)", "1");
    assert_eval(s, "(begin 1 2)", "2");
    assert_eval(s, "(begin 1 2 3)", "3");
}

void test_quote() {
    Scheme* s = new Scheme();
    assert_eval(s, "'()", "()");
    assert_eval(s, "'(a b c)", "(a b c)");
    assert_eval(s, "'a", "a");
    assert_eval(s, "'1", "1");
    assert_eval(s, "(number? 1)", "#t");
    assert_eval(s, "(bool? '#t)", "#t");
}

void test_vector() {
    Scheme* s = new Scheme();
    assert_eval(s, "(make-vector 5 'a)", "#(a a a a a)");
    assert_eval(s, "(make-vector 2 (+ 5 1))", "#(6 6)");
    assert_eval(s, "(vector? (make-vector 5 'a))", "#t");
    assert_eval(s, "(vector? 5)", "#f");
    assert_eval(s, "(vector 5 'a (+ 1 2) \"z\")", "#(5 a 3 \"z\")");
    assert_eval(s, "(vector)", "#()");
    assert_eval(s, "'#(a b c)", "#(a b c)");
    assert_eval(s, "(vector? (vector))", "#t");
    assert_eval(s, "(vector-length (vector))", "0");
    assert_eval(s, "(vector-length (vector 'a 'b))", "2");
    assert_eval(s, "(vector-length #())", "0");
    assert_eval(s, "(vector-length #(1 (1 2) 3))", "3");
    
}

int main(int argc, char *argv[]) {
    try {
        cout << "Test tokenizer...       ";
        test_tokenizer();
        cout << " OK" << endl;
        test_parser();
        test_interpreter();
        test_bools();
        test_symbols();

        cout << "Test equals...          ";
        test_equals();
        cout << " OK" << endl;

        cout << "Test pairs and lists... ";
        test_pairs_and_lists();
        cout << " OK" << endl;

        cout << "Test lambda...          ";
        test_lambda();
        cout << " OK" << endl;

        cout << "Test vector...          ";
        test_vector();
        cout << " OK" << endl;


        test_define_and_set();
        test_string();
        test_begin();
        test_quote();
    } catch (scheme_exception e) {
		cerr << "Exception: " << e.str << endl;
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}