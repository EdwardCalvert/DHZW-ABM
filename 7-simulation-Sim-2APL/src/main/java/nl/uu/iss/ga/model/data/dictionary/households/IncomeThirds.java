package main.java.nl.uu.iss.ga.model.data.dictionary.households;

import main.java.nl.uu.iss.ga.model.data.dictionary.util.StringCodeTypeInterface;

public enum IncomeThirds implements StringCodeTypeInterface {
    LOW("low"),
    AVERAGE("average"),
    HIGH("high");
    private final int code;
    private final String stringCode;
    IncomeThirds(String code){
        this.stringCode = code;
        this.code = StringCodeTypeInterface.parseStringCode(code);
    }

    @Override
    public int getCode() {
        return code;
    }

    @Override
    public String getStringCode() {
        return stringCode;
    }
}
