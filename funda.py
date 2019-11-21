# -*- coding: utf-8 -*-

import scrapy

class FundaSpider(scrapy.Spider):
    name = 'funda'
    allowed_domains = ['www.funda.nl']
    start_urls = ['file:///C:/Users/arjan/Documents/Digital%20Driven%20Business/2.1%20Online%20Data%20Mining/Huis%20te%20koop_%20Eschweilerhof%2013%205625%20NM%20Eindhoven%20[funda].html']

    def parse(self, response):
        yield{
            'Energylabel': response.css('dl.object-kenmerken-list > dd > span:nth-of-type(18)::text').extract_first(),
            'Isolation': response.css('dl.object-kenmerken-list > dd:nth-of-type(19)::text').extract_first()
        }
