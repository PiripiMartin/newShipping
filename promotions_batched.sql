-- =====================================================
-- Promotions INSERT Script
-- All 41 promotions
-- Generated: 2025-09-20 18:55:50
-- =====================================================

USE Shipping;

-- Disable checks for faster loading
SET AUTOCOMMIT = 0;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;

INSERT INTO promotions (promotionDescription, startDate, endDate, day, weekNumber, calendarYear, financialYear) VALUES
('Afterpay Day: Everything on Sale + EXTRA 20% OFF', '2024-03-05', '2025-03-23', 'Tuesday', 37, 2024, 2024),
('Big Brand Sale: Up to xx% off', '2024-07-09', '2024-07-24', 'Tuesday', 2, 2024, 2025),
('Black Friday - Everything on Sale + EXTRA 20% off Sitewide', '2024-11-21', '2024-12-02', 'Thursday', 21, 2024, 2025),
('Boxing Day Sale - Everything on Sale + TAE20% off Sitewide', '2024-12-16', '2024-12-29', 'Monday', 25, 2024, 2025),
('Easter Entertaining', '2025-03-24', '2025-04-14', 'Monday', 39, 2025, 2025),
('Easter Entertaining Up to 75% off', '2024-03-19', '2024-04-01', 'Tuesday', 39, 2024, 2024),
('Embrace Autumn with Seasonal Cookware + Ecology Giveaway', '2024-04-16', '2024-04-22', 'Tuesday', 43, 2024, 2024),
('Extra 20% off ALL Cookware', '2024-10-22', '2024-10-28', 'Tuesday', 17, 2024, 2025),
('Frenzy: Everything on Sale + EXTRA 20% off Sitewide', '2024-11-07', '2024-11-18', 'Thursday', 19, 2024, 2025),
('Get Guest Ready', '2024-12-03', '2024-12-15', 'Tuesday', 23, 2024, 2025),
('Gold Medal Deals / Savings / Olympics Inspired Up to XX% off', '2024-07-25', '2024-08-05', 'Thursday', 4, 2024, 2025),
('Half Price or Better everything in this sale', '2025-01-29', '2025-02-10', 'Wednesday', 31, 2025, 2025),
('Half Price or better Everything in this Sale', '2024-01-30', '2024-02-08', 'Tuesday', 32, 2024, 2024),
('HALF PRICE SALE EVERYTHING IN THIS SALE 50 -75% OFF + FATHERS DAY FEATURES', '2024-08-20', '2024-09-01', 'Tuesday', 8, 2024, 2025),
('Here Comes Winter Sale up to XX% off', '2024-05-21', '2024-06-03', 'Tuesday', 48, 2024, 2024),
('House Frenzy Everythig on sale +extra 20% off', '2024-05-10', '2024-05-20', 'Friday', 46, 2024, 2024),
('House Frenzy: Everything on Sale + EXTRA 20% off Sitewide', '2025-05-09', '2025-05-19', 'Friday', 45, 2025, 2025),
('Jan Clearance Up to XX % off', '2025-01-03', '2025-01-20', 'Friday', 27, 2025, 2025),
('June Clearance', '2025-06-03', '2025-06-19', 'Tuesday', 49, 2025, 2025),
('JUNE CLEARANCE: Up to xx% off', '2024-06-04', '2024-06-18', 'Tuesday', 50, 2024, 2024),
('LAST CHANCE NEW YEARS DAY 20% off EVERYTHING on SALE', '2024-01-01', '2024-01-02', 'Monday', 28, 2024, 2024),
('Massive Kitchen Runout', '2025-02-11', '2025-03-03', 'Tuesday', 33, 2025, 2025),
('Massive Kitchen Runout $20 off Orders over $149', '2024-02-09', '2024-02-19', 'Friday', 33, 2024, 2024),
('Massive Kitchen Runout Save up to 70% off', '2024-02-20', '2024-03-04', 'Tuesday', 35, 2024, 2024),
('MEGA EOFY SALE UP TO 75% OFF RRP* +EXTRA 20% OFF ALL SALE', '2024-06-21', '2025-07-06', 'Friday', 52, 2024, 2024),
('Mega Sitewide Sale up to 70% off', '2025-03-11', '2025-03-14', 'Tuesday', 37, 2025, 2025),
('Mid Season Sale EXTRA 20% OFF ALL COOKWARE', '2024-04-02', '2025-04-27', 'Tuesday', 41, 2024, 2024),
('Mid Season Sale Up to xx % off', '2024-10-01', '2024-10-21', 'Tuesday', 14, 2024, 2025),
('Mothers Day Gifting', '2024-04-23', '2025-05-08', 'Tuesday', 44, 2024, 2024),
('NEW YEARS DAY SALE 20% off EVERYTHING on SALE', '2024-12-30', '2025-01-02', 'Monday', 27, 2024, 2025),
('Our Hottest Ever Winter Sale', '2025-05-20', '2025-06-02', 'Tuesday', 47, 2025, 2025),
('PAYPAL FRENZY $20 off Orders Over $159', '2025-03-04', '2025-03-10', 'Tuesday', 36, 2025, 2025),
('Spend & Save $20 off Orders Over $149', '2024-07-02', '2024-07-08', 'Tuesday', 1, 2024, 2025),
('Spring Refresh Up to XX% off', '2024-09-02', '2024-09-16', 'Monday', 10, 2024, 2025),
('STOCK LIQUIDATION UP TO 75% OFF RRP* EVERYTHING $99 OR LESS IN THIS SALE', '2024-06-19', '2024-06-20', 'Wednesday', 52, 2024, 2024),
('Sun-Sational Summer Savings Up to 75% off', '2024-01-03', '2024-01-15', 'Wednesday', 28, 2024, 2024),
('Super Sets extra 20% off sets', '2025-01-21', '2025-01-28', 'Tuesday', 30, 2025, 2025),
('Super Sets Up to 75% off', '2024-01-16', '2024-01-29', 'Tuesday', 30, 2024, 2024),
('XMAS assets - no EDMs', '2024-11-19', '2024-11-20', 'Tuesday', 21, 2024, 2025),
('Xmas Gift Guide', '2024-10-29', '2024-11-06', 'Tuesday', 18, 2024, 2025),
('Entertainer\'s Edit -Free Gift Orders Over $179 + Free Otto Glasses', '2024-09-17', '2024-09-30', 'Tuesday', 12, 2024, 2025);

-- Re-enable checks
COMMIT;
SET AUTOCOMMIT = 1;
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;

-- Verify promotions count
SELECT COUNT(*) as total_promotions FROM promotions;
SELECT 'Promotions loading complete!' as status;
