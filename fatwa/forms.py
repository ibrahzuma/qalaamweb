from django import forms
from .models import Fatwa

class FatwaForm(forms.ModelForm):
    class Meta:
        model = Fatwa
        fields = ['title', 'question', 'category']
        widgets = {
            'title': forms.TextInput(attrs={'class': 'form-control'}),
            'question': forms.Textarea(attrs={'class': 'form-control', 'rows': 5}),
            'category': forms.Select(attrs={'class': 'form-control'}),
        }
