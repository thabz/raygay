
#ifndef SCHEME_OBJECTS_H
#define SCHEME_OBJECTS_H

#include <string>
#include <map>

class BindingEnvironment;

using namespace std;

class SchemeObject {
    public:
	    enum ObjectType {
		    NUMBER,
		    EMPTY_LIST,
		    SYMBOL,
		    BOOL,
		    STRING,
		    VECTOR,
		    PAIR,
		    UNSPECIFIED,
 		    PROCEDURE
		};
        virtual ~SchemeObject() {};
        virtual string toString() = 0;
        virtual bool boolValue() const { return true; }; // Used in conditional expressions (if, cond, and, or, do)
		virtual ObjectType type() = 0;
};

class SchemeUnspecified : public SchemeObject {
    public:
        string toString();
        ObjectType type() { return UNSPECIFIED; };
};

class SchemeNumber : public SchemeObject {
    public:
       SchemeNumber(double number);
       string toString();
       double number;
  	   ObjectType type() { return NUMBER; };
};

class SchemePair : public SchemeObject {
    public:
        SchemePair();
        SchemePair(SchemeObject* car, SchemeObject* cdr);
		SchemePair* cdrAsPair();
        ObjectType type() { return PAIR; };
        
        string toString();
	    SchemeObject* car;
     	SchemeObject* cdr;
};

class SchemeVector : public SchemeObject {
    public:
        SchemeVector(SchemeObject** elems, int length);
        SchemeVector(SchemeObject* elems, int length);
        SchemeObject* get(int index);
        void set(SchemeObject* o, int index);
        ObjectType type() { return VECTOR; };
        
        string toString();
        SchemeObject** elems;
        int length;
};


class SchemeEmptyList : public SchemePair {
    public:
        string toString();
        ObjectType type() { return EMPTY_LIST; };
};

class SchemeSymbol : public SchemeObject {
    public:
        static SchemeSymbol* create(string s);
        string toString();
        ObjectType type() { return SYMBOL; };
	    std::string str;
	private:
        SchemeSymbol(string s);
        static map<string,SchemeSymbol*> symbols;    
};


class SchemeString : public SchemeObject {
    public:
        SchemeString(string s);
        string toString();
        ObjectType type() { return STRING; };
	    std::string str;

};

class SchemeBool : public SchemeObject {
    public:
        SchemeBool(bool b);
        string toString();
        ObjectType type() { return BOOL; };
    	bool boolean;
	    bool boolValue() const { return boolean; };
};

class SchemeProcedure : public SchemeObject 
{
    public:
        SchemeProcedure(int req, int opt, int rst, SchemeObject* (*fn)());
        SchemeProcedure(BindingEnvironment* envt, SchemePair* s_req, SchemeSymbol* s_rst, SchemePair* s_body);
        string toString();      
        ObjectType type() { return PROCEDURE; };

        // Fields for builtin
        int req;
        int opt;
        int rst;
        SchemeObject* (*fn)();
        
        // Fields for user-function
        SchemePair* s_body;
        SchemePair* s_req;
        SchemeSymbol* s_rst;
        BindingEnvironment* envt;
};

#endif