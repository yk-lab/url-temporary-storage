$(function() {
    var GridForms = {
        el: {
            fieldsRows: $('[data-row-span]'),
            fieldsContainers: $('[data-field-span]'),
            focusableFields: $('input, textarea, select', '[data-field-span]'),
            window: $(window)
        },
        init: function() {
            this.focusField(this.el.focusableFields.filter(':focus'));
            this.equalizeFieldHeights();
            this.events();
        },
        focusField: function(currentField) {
            currentField.closest('[data-field-span]').addClass('focus');
        },
        removeFieldFocus: function() {
            this.el.fieldsContainers.removeClass('focus');
        },
        events: function() {
            var that = this;
            that.el.fieldsContainers.click(function() {
                $(this).find('input[type="text"], input[type="password"], textarea, select').focus();
            });
            that.el.focusableFields.focus(function() {
                that.focusField($(this));
            });
            that.el.focusableFields.blur(function() {
                that.removeFieldFocus();
            });
            that.el.window.resize(function() {
                that.equalizeFieldHeights();
            });

        },
        equalizeFieldHeights: function() {
            this.el.fieldsContainers.css("height", "auto");

            var fieldsRows = this.el.fieldsRows;
            var fieldsContainers = this.el.fieldsContainers;

            // Make sure that the fields aren't stacked
            if (!this.areFieldsStacked()) {
                fieldsRows.each(function() {
                    // Get the height of the row (thus the tallest element's height)
                    var fieldRow = $(this);
                    var rowHeight = fieldRow.css('height');

                    // Set the height for each field in the row...
                    fieldRow.find(fieldsContainers).css('height', rowHeight);
                });
            }
        },
        areFieldsStacked: function() {
            // Get the first row 
            // which does not only contain one field 
            var firstRow = this.el.fieldsRows
                .not('[data-row-span="1"]')
                .first();

            // Get to the total width 
            // of each field witin the row
            var totalWidth = 0;
            firstRow.children().each(function() {
                totalWidth += $(this).width();
            });

            // Determine whether fields are stacked or not
            return firstRow.width() <= totalWidth;
        }
    };
    GridForms.init();
});