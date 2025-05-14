/**
 * @description Invocable Apex class that handles various date and datetime operations
 * This class can be used in Flow, Process Builder, or other automation tools
 */
public with sharing class DateTimeOperationsInvocable {
    
    /**
     * @description Enum representing the supported date/time operations
     */
    public enum Operation {
        ADD_DAYS,
        ADD_MONTHS,
        ADD_YEARS,
        SUBTRACT_DAYS,
        SUBTRACT_MONTHS,
        SUBTRACT_YEARS,
        FORMAT_DATE,
        GET_DAY_OF_WEEK,
        GET_DAY_OF_YEAR,
        DATE_DIFF_IN_DAYS,
        DATE_DIFF_IN_MONTHS,
        DATE_DIFF_IN_YEARS,
        IS_LEAP_YEAR,
        TODAY,
        NOW
    }
    
    /**
     * @description Request class to hold input parameters for the invocable method
     */
    public class DateTimeOperationRequest {
        @InvocableVariable(label='Operation' required=true description='The date/time operation to perform')
        public String operation;
        
        @InvocableVariable(label='Input Date' required=false description='The input date for the operation')
        public Date inputDate;
        
        @InvocableVariable(label='Input DateTime' required=false description='The input datetime for the operation')
        public Datetime inputDateTime;
        
        @InvocableVariable(label='Second Date' required=false description='Secondary date for operations like date difference')
        public Date secondDate;
        
        @InvocableVariable(label='Second DateTime' required=false description='Secondary datetime for operations like date difference')
        public Datetime secondDateTime;
        
        @InvocableVariable(label='Value' required=false description='Numeric value for operations like adding days')
        public Integer value;
        
        @InvocableVariable(label='Format' required=false description='Format string for date formatting')
        public String format;
    }
    
    /**
     * @description Response class to hold the result of the date/time operation
     */
    public class DateTimeOperationResponse {
        @InvocableVariable(label='Result Date')
        public Date resultDate;
        
        @InvocableVariable(label='Result DateTime')
        public Datetime resultDateTime;
        
        @InvocableVariable(label='Result Text')
        public String resultText;
        
        @InvocableVariable(label='Result Number')
        public Integer resultNumber;
        
        @InvocableVariable(label='Result Boolean')
        public Boolean resultBoolean;
    }
    
    /**
     * @description Invocable method that performs the requested date/time operation
     * @param requests List of operation requests
     * @return List of operation results
     */
    @InvocableMethod(label='Perform Date/Time Operation' description='Performs various date and datetime operations')
    public static List<DateTimeOperationResponse> performDateTimeOperation(List<DateTimeOperationRequest> requests) {
        List<DateTimeOperationResponse> responses = new List<DateTimeOperationResponse>();
        
        for (DateTimeOperationRequest req : requests) {
            DateTimeOperationResponse response = new DateTimeOperationResponse();
            Operation op;
            
            try {
                op = Operation.valueOf(req.operation.toUpperCase());
            } catch (Exception e) {
                response.resultText = 'Error: Invalid operation "' + req.operation + '". Please use one of the supported operations.';
                responses.add(response);
                continue;
            }
            
            switch on op {
                when ADD_DAYS {
                    if (req.inputDate != null) {
                        response.resultDate = req.inputDate.addDays(req.value);
                    } else if (req.inputDateTime != null) {
                        response.resultDateTime = req.inputDateTime.addDays(req.value);
                    } else {
                        response.resultText = 'Error: ADD_DAYS requires inputDate or inputDateTime and value to be provided';
                    }
                }
                when ADD_MONTHS {
                    if (req.inputDate != null) {
                        response.resultDate = req.inputDate.addMonths(req.value);
                    } else if (req.inputDateTime != null) {
                        response.resultDateTime = req.inputDateTime.addMonths(req.value);
                    } else {
                        response.resultText = 'Error: ADD_MONTHS requires inputDate or inputDateTime and value to be provided';
                    }
                }
                when ADD_YEARS {
                    if (req.inputDate != null) {
                        response.resultDate = req.inputDate.addYears(req.value);
                    } else if (req.inputDateTime != null) {
                        response.resultDateTime = req.inputDateTime.addYears(req.value);
                    } else {
                        response.resultText = 'Error: ADD_YEARS requires inputDate or inputDateTime and value to be provided';
                    }
                }
                when SUBTRACT_DAYS {
                    if (req.inputDate != null) {
                        response.resultDate = req.inputDate.addDays(-req.value);
                    } else if (req.inputDateTime != null) {
                        response.resultDateTime = req.inputDateTime.addDays(-req.value);
                    } else {
                        response.resultText = 'Error: SUBTRACT_DAYS requires inputDate or inputDateTime and value to be provided';
                    }
                }
                when SUBTRACT_MONTHS {
                    if (req.inputDate != null) {
                        response.resultDate = req.inputDate.addMonths(-req.value);
                    } else if (req.inputDateTime != null) {
                        response.resultDateTime = req.inputDateTime.addMonths(-req.value);
                    } else {
                        response.resultText = 'Error: SUBTRACT_MONTHS requires inputDate or inputDateTime and value to be provided';
                    }
                }
                when SUBTRACT_YEARS {
                    if (req.inputDate != null) {
                        response.resultDate = req.inputDate.addYears(-req.value);
                    } else if (req.inputDateTime != null) {
                        response.resultDateTime = req.inputDateTime.addYears(-req.value);
                    } else {
                        response.resultText = 'Error: SUBTRACT_YEARS requires inputDate or inputDateTime and value to be provided';
                    }
                }
                when FORMAT_DATE {
                    if (req.inputDate != null && req.format != null) {
                        Datetime dt = Datetime.newInstance(req.inputDate.year(), req.inputDate.month(), req.inputDate.day());
                        response.resultText = dt.format(req.format);
                    } else if (req.inputDateTime != null && req.format != null) {
                        response.resultText = req.inputDateTime.format(req.format);
                    } else {
                        response.resultText = 'Error: FORMAT_DATE requires inputDate or inputDateTime and format to be provided';
                    }
                }
                when GET_DAY_OF_WEEK {
                    if (req.inputDate != null) {
                        // Returns 1 (Monday) through 7 (Sunday)
                        response.resultNumber = Math.mod(Date.newInstance(1900, 1, 7).daysBetween(req.inputDate), 7) + 1;
                    } else if (req.inputDateTime != null) {
                        Date dt = Date.newInstance(req.inputDateTime.year(), req.inputDateTime.month(), req.inputDateTime.day());
                        response.resultNumber = Math.mod(Date.newInstance(1900, 1, 7).daysBetween(dt), 7) + 1;
                    } else {
                        response.resultText = 'Error: GET_DAY_OF_WEEK requires inputDate or inputDateTime to be provided';
                    }
                }
                when GET_DAY_OF_YEAR {
                    if (req.inputDate != null) {
                        Date startOfYear = Date.newInstance(req.inputDate.year(), 1, 1);
                        response.resultNumber = startOfYear.daysBetween(req.inputDate) + 1;
                    } else if (req.inputDateTime != null) {
                        Date dt = Date.newInstance(req.inputDateTime.year(), req.inputDateTime.month(), req.inputDateTime.day());
                        Date startOfYear = Date.newInstance(dt.year(), 1, 1);
                        response.resultNumber = startOfYear.daysBetween(dt) + 1;
                    } else {
                        response.resultText = 'Error: GET_DAY_OF_YEAR requires inputDate or inputDateTime to be provided';
                    }
                }
                when DATE_DIFF_IN_DAYS {
                    if (req.inputDate != null && req.secondDate != null) {
                        response.resultNumber = req.inputDate.daysBetween(req.secondDate);
                    } else if (req.inputDateTime != null && req.secondDateTime != null) {
                        // Convert to milliseconds, then to days
                        Long diffMillis = req.secondDateTime.getTime() - req.inputDateTime.getTime();
                        response.resultNumber = Integer.valueOf(diffMillis / (1000 * 60 * 60 * 24));
                    } else {
                        response.resultText = 'Error: DATE_DIFF_IN_DAYS requires both inputDate and secondDate, or both inputDateTime and secondDateTime';
                    }
                }
                when DATE_DIFF_IN_MONTHS {
                    if (req.inputDate != null && req.secondDate != null) {
                        // Calculate year and month differences
                        Integer yearDiff = req.secondDate.year() - req.inputDate.year();
                        Integer monthDiff = req.secondDate.month() - req.inputDate.month();
                        response.resultNumber = (yearDiff * 12) + monthDiff;
                    } else if (req.inputDateTime != null && req.secondDateTime != null) {
                        // Calculate year and month differences
                        Integer yearDiff = req.secondDateTime.year() - req.inputDateTime.year();
                        Integer monthDiff = req.secondDateTime.month() - req.inputDateTime.month();
                        response.resultNumber = (yearDiff * 12) + monthDiff;
                    } else {
                        response.resultText = 'Error: DATE_DIFF_IN_MONTHS requires both inputDate and secondDate, or both inputDateTime and secondDateTime';
                    }
                }
                when DATE_DIFF_IN_YEARS {
                    if (req.inputDate != null && req.secondDate != null) {
                        // Calculate year difference
                        response.resultNumber = req.secondDate.year() - req.inputDate.year();
                    } else if (req.inputDateTime != null && req.secondDateTime != null) {
                        // Calculate year difference
                        response.resultNumber = req.secondDateTime.year() - req.inputDateTime.year();
                    } else {
                        response.resultText = 'Error: DATE_DIFF_IN_YEARS requires both inputDate and secondDate, or both inputDateTime and secondDateTime';
                    }
                }
                when IS_LEAP_YEAR {
                    Integer year = 0;
                    if (req.inputDate != null) {
                        year = req.inputDate.year();
                    } else if (req.inputDateTime != null) {
                        year = req.inputDateTime.year();
                    } else if (req.value != null) {
                        year = req.value;
                    } else {
                        response.resultText = 'Error: IS_LEAP_YEAR requires inputDate, inputDateTime, or value (year) to be provided';
                        responses.add(response);
                        continue;
                    }
                    
                    // Leap year calculation
                    Boolean isLeap = Math.mod(year, 4) == 0 && (Math.mod(year, 100) != 0 || Math.mod(year, 400) == 0);
                    response.resultBoolean = isLeap;
                }
                when TODAY {
                    response.resultDate = Date.today();
                }
                when NOW {
                    response.resultDateTime = Datetime.now();
                }
            }
            
            responses.add(response);
        }
        
        return responses;
    }
}