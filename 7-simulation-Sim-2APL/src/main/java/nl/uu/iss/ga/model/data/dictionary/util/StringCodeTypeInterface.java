package main.java.nl.uu.iss.ga.model.data.dictionary.util;

public interface StringCodeTypeInterface extends CodeTypeInterface {

    String getStringCode();

    static <E extends Enum<E> & StringCodeTypeInterface> E valueOfCodeString(Class<E> eClass, String code) {
        for ( final E enumConstant : eClass.getEnumConstants() ) {
            if (code.equals(enumConstant.getStringCode())) {
                return enumConstant;
            }
        }
        return null;
    }

    static int parseStringCode(String stringCode) {
        return parseStringCode(stringCode, -1); //Method overload to supply default value.
    }

    static int parseStringCode(String stringCode, int defaultInteger) {

        if (stringCode == null) {
            return defaultInteger;
        }
        try {
            // Check if the string is a valid integer (including negative sign)
            if (stringCode.matches("-?\\d+")) {
                return Integer.parseInt(stringCode);
            }
        }
        catch (NumberFormatException e){
            return defaultInteger;
        }
        // If not an integer, return the hash of the string
        return stringCode.hashCode();
    }

    static <T extends Enum<T> & StringCodeTypeInterface> T parseAsEnum(Class<T> type, String codeValue) {
        return StringCodeTypeInterface.valueOfCodeString(type, codeValue);
    }
}
